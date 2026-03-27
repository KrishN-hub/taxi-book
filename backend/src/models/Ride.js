const mongoose = require('mongoose');

const rideSchema = new mongoose.Schema(
  {
    passenger: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    driver: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver' },
    pickup: {
      address: { type: String, required: true },
      location: {
        type: { type: String, enum: ['Point'], default: 'Point' },
        coordinates: { type: [Number], required: true }, // [lng, lat]
      },
    },
    drop: {
      address: { type: String, required: true },
      location: {
        type: { type: String, enum: ['Point'], default: 'Point' },
        coordinates: { type: [Number], required: true }, // [lng, lat]
      },
    },
    fareAmount: { type: Number, default: 0 },
    distanceKm: { type: Number, default: 0 },
    status: {
      type: String,
      enum: ['requested', 'accepted', 'started', 'completed', 'cancelled'],
      default: 'requested',
    },
    requestedAt: { type: Date, default: Date.now },
    acceptedAt: { type: Date },
    startedAt: { type: Date },
    completedAt: { type: Date },
    passengerRating: { type: Number, min: 1, max: 5 },
    passengerReview: { type: String, trim: true },
  },
  { timestamps: true }
);

rideSchema.index({ 'pickup.location': '2dsphere' });

module.exports = mongoose.model('Ride', rideSchema);
