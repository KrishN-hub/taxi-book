const express = require('express');
const {
  login,
  logout,
  signup,
  firebaseLogin,
  registerDeviceToken,
} = require('../controllers/auth.controller');
const { verifyAuth } = require('../middlewares/auth.middleware');

const router = express.Router();

router.post('/signup', signup);
router.post('/login', login);
router.post('/firebase-login', firebaseLogin);
router.post('/logout', verifyAuth, logout);
router.post('/device-token', verifyAuth, registerDeviceToken);

module.exports = router;
