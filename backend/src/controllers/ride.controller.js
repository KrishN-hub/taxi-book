const Driver = require('../models/Driver');
const Ride = require('../models/Ride');
const User = require('../models/User');
const { getIo } = require('../sockets/socket');
const { driverSocketMap, passengerSocketMap } = require('../utils/socketState');
const { sendPushNotification } = require('../services/notification.service');

async function requestRide(req, res) {
  try {
    const { pickupAddress, pickupLng, pickupLat, dropAddress, dropLng, dropLat } = req.body;
    if (
      !pickupAddress ||
      !dropAddress ||
      typeof pickupLng !== 'number' ||
      typeof pickupLat !== 'number' ||
      typeof dropLng !== 'number' ||
      typeof dropLat !== 'number'
    ) {
      return res.status(400).json({ message: 'Invalid pickup/drop data' });
    }

    const ride = await Ride.create({
      passenger: req.user._id,
      pickup: {
        address: pickupAddress,
        location: { type: 'Point', coordinates: [pickupLng, pickupLat] },
      },
      drop: {
        address: dropAddress,
        location: { type: 'Point', coordinates: [dropLng, dropLat] },
      },
      status: 'requested',
    });

    // Find nearby available drivers (within 10 km)
    const nearbyDrivers = await Driver.find({
      isOnline: true,
      isAvailable: true,
      location: {
        $near: {
          $geometry: { type: 'Point', coordinates: [pickupLng, pickupLat] },
          $maxDistance: 10000,
        },
      },
    }).limit(20);

    const io = getIo();
    for (const driver of nearbyDrivers) {
      const driverSocketId = driverSocketMap.get(driver._id.toString());
      if (driverSocketId) {
        io.to(driverSocketId).emit('ride:request:new', { ride });
      }
    }

    return res.status(201).json({ message: 'Ride requested', ride, nearbyDrivers: nearbyDrivers.length });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to request ride', error: error.message });
  }
}

async function getNearbyDrivers(req, res) {
  try {
    const lng = Number(req.query.lng);
    const lat = Number(req.query.lat);
    const radius = Number(req.query.radius || 10000);

    if (Number.isNaN(lng) || Number.isNaN(lat)) {
      return res.status(400).json({ message: 'lng and lat are required query params' });
    }

    const drivers = await Driver.find({
      isOnline: true,
      isAvailable: true,
      location: {
        $near: {
          $geometry: { type: 'Point', coordinates: [lng, lat] },
          $maxDistance: radius,
        },
      },
    }).populate('user', 'name phone ratingAverage');

    return res.status(200).json({ drivers });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch nearby drivers', error: error.message });
  }
}

async function acceptRide(req, res) {
  try {
    const { rideId } = req.body;
    if (!rideId) return res.status(400).json({ message: 'rideId is required' });

    const driver = await Driver.findOne({ user: req.user._id });
    if (!driver) return res.status(404).json({ message: 'Driver profile not found' });

    const ride = await Ride.findOneAndUpdate(
      { _id: rideId, status: 'requested' },
      {
        driver: driver._id,
        status: 'accepted',
        acceptedAt: new Date(),
      },
      { new: true }
    );

    if (!ride) return res.status(409).json({ message: 'Ride already accepted or unavailable' });

    await Driver.findByIdAndUpdate(driver._id, { isAvailable: false });

    const io = getIo();
    io.to(`ride:${ride._id}`).emit('ride:status:updated', { rideId: ride._id, status: 'accepted' });

    const passengerSocketId = passengerSocketMap.get(ride.passenger.toString());
    if (passengerSocketId) {
      io.to(passengerSocketId).emit('ride:accepted', { ride });
    }

    // Optional FCM push for offline passenger device.
    const passenger = await User.findById(ride.passenger).select('deviceToken');
    if (passenger?.deviceToken) {
      await sendPushNotification({
        token: passenger.deviceToken,
        title: 'Ride Accepted',
        body: 'A driver accepted your ride request.',
        data: { rideId: ride._id.toString(), status: 'accepted' },
      });
    }

    return res.status(200).json({ message: 'Ride accepted', ride });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to accept ride', error: error.message });
  }
}

async function completeRide(req, res) {
  try {
    const { rideId, fareAmount, distanceKm } = req.body;
    if (!rideId) return res.status(400).json({ message: 'rideId is required' });

    const ride = await Ride.findById(rideId);
    if (!ride) return res.status(404).json({ message: 'Ride not found' });
    if (ride.status === 'completed') return res.status(409).json({ message: 'Ride already completed' });

    ride.status = 'completed';
    ride.completedAt = new Date();
    if (typeof fareAmount === 'number') ride.fareAmount = fareAmount;
    if (typeof distanceKm === 'number') ride.distanceKm = distanceKm;
    await ride.save();

    if (ride.driver) {
      await Driver.findByIdAndUpdate(ride.driver, { isAvailable: true });
    }

    const io = getIo();
    io.to(`ride:${ride._id}`).emit('ride:status:updated', { rideId: ride._id, status: 'completed' });

    return res.status(200).json({ message: 'Ride completed', ride });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to complete ride', error: error.message });
  }
}

async function getMyRides(req, res) {
  try {
    const rides = await Ride.find({ passenger: req.user._id })
      .populate({ path: 'driver', populate: { path: 'user', select: 'name phone' } })
      .sort({ createdAt: -1 });

    return res.status(200).json({ rides });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch ride history', error: error.message });
  }
}

async function rateRide(req, res) {
  try {
    const { rideId, rating, review } = req.body;
    if (!rideId || !rating) return res.status(400).json({ message: 'rideId and rating are required' });
    if (rating < 1 || rating > 5) return res.status(400).json({ message: 'rating must be 1-5' });

    const ride = await Ride.findOne({ _id: rideId, passenger: req.user._id });
    if (!ride) return res.status(404).json({ message: 'Ride not found' });
    if (ride.status !== 'completed') return res.status(409).json({ message: 'Ride not completed yet' });

    ride.passengerRating = rating;
    ride.passengerReview = review || '';
    await ride.save();

    return res.status(200).json({ message: 'Rating submitted', ride });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to submit rating', error: error.message });
  }
}

module.exports = {
  requestRide,
  getNearbyDrivers,
  acceptRide,
  completeRide,
  getMyRides,
  rateRide,
};
