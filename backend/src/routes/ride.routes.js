const express = require('express');
const {
  requestRide,
  getNearbyDrivers,
  acceptRide,
  completeRide,
  getMyRides,
  rateRide,
} = require('../controllers/ride.controller');
const { verifyAuth, requireRole } = require('../middlewares/auth.middleware');

const router = express.Router();

router.post('/request', verifyAuth, requireRole('passenger', 'admin'), requestRide);
router.get('/nearby', verifyAuth, getNearbyDrivers);
router.post('/accept', verifyAuth, requireRole('driver', 'admin'), acceptRide);
router.post('/complete', verifyAuth, requireRole('driver', 'admin'), completeRide);
router.get('/history', verifyAuth, requireRole('passenger', 'admin'), getMyRides);
router.post('/rate', verifyAuth, requireRole('passenger', 'admin'), rateRide);

module.exports = router;
