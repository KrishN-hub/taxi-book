const Payment = require('../models/Payment');
const Ride = require('../models/Ride');
const { getRazorpayClient, getStripeClient } = require('../services/payment.service');

async function createPayment(req, res) {
  try {
    const { rideId, provider = 'stripe', currency = 'INR' } = req.body;
    if (!rideId) return res.status(400).json({ message: 'rideId is required' });

    const ride = await Ride.findById(rideId);
    if (!ride) return res.status(404).json({ message: 'Ride not found' });
    if (String(ride.passenger) !== String(req.user._id)) {
      return res.status(403).json({ message: 'Not allowed for this ride' });
    }
    if (!ride.fareAmount || ride.fareAmount <= 0) {
      return res.status(400).json({ message: 'Ride fareAmount must be set before payment' });
    }

    const amountInMinorUnit = Math.round(ride.fareAmount * 100);

    if (provider === 'stripe') {
      const stripe = getStripeClient();
      if (!stripe) return res.status(500).json({ message: 'Stripe not configured' });

      const paymentIntent = await stripe.paymentIntents.create({
        amount: amountInMinorUnit,
        currency: currency.toLowerCase(),
        metadata: { rideId: ride._id.toString() },
      });

      const payment = await Payment.create({
        ride: ride._id,
        passenger: req.user._id,
        amount: ride.fareAmount,
        currency,
        provider: 'stripe',
        providerPaymentIntentId: paymentIntent.id,
        status: 'pending',
      });

      return res.status(201).json({
        message: 'Stripe payment intent created',
        payment,
        clientSecret: paymentIntent.client_secret,
      });
    }

    if (provider === 'razorpay') {
      const razorpay = getRazorpayClient();
      if (!razorpay) return res.status(500).json({ message: 'Razorpay not configured' });

      const order = await razorpay.orders.create({
        amount: amountInMinorUnit,
        currency,
        receipt: `ride_${ride._id}`,
      });

      const payment = await Payment.create({
        ride: ride._id,
        passenger: req.user._id,
        amount: ride.fareAmount,
        currency,
        provider: 'razorpay',
        providerOrderId: order.id,
        status: 'pending',
      });

      return res.status(201).json({
        message: 'Razorpay order created',
        payment,
        razorpayOrder: order,
      });
    }

    return res.status(400).json({ message: 'Unsupported provider' });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to create payment', error: error.message });
  }
}

async function confirmPayment(req, res) {
  try {
    const { paymentId, status = 'paid' } = req.body;
    if (!paymentId) return res.status(400).json({ message: 'paymentId is required' });

    const payment = await Payment.findById(paymentId);
    if (!payment) return res.status(404).json({ message: 'Payment not found' });
    if (String(payment.passenger) !== String(req.user._id)) {
      return res.status(403).json({ message: 'Not allowed for this payment' });
    }

    payment.status = status;
    await payment.save();

    return res.status(200).json({ message: 'Payment status updated', payment });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to confirm payment', error: error.message });
  }
}

module.exports = { createPayment, confirmPayment };
