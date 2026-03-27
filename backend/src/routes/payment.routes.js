const express = require('express');
const { createPayment, confirmPayment } = require('../controllers/payment.controller');
const { verifyAuth, requireRole } = require('../middlewares/auth.middleware');

const router = express.Router();

router.post('/create', verifyAuth, requireRole('passenger', 'admin'), createPayment);
router.post('/confirm', verifyAuth, requireRole('passenger', 'admin'), confirmPayment);

module.exports = router;
