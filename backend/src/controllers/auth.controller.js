const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Driver = require('../models/Driver');
const { generateAccessToken } = require('../utils/token');

async function signup(req, res) {
  try {
    const { name, email, password, phone, role = 'passenger', firebaseUid } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'name, email and password are required' });
    }

    const existing = await User.findOne({ email });
    if (existing) return res.status(409).json({ message: 'Email already exists' });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      email,
      phone,
      role,
      firebaseUid,
      passwordHash,
    });

    if (role === 'driver') {
      await Driver.create({ user: user._id });
    }

    const token = generateAccessToken(user);
    return res.status(201).json({
      message: 'Signup successful',
      token,
      user,
    });
  } catch (error) {
    return res.status(500).json({ message: 'Signup failed', error: error.message });
  }
}

async function login(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user || !user.passwordHash) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isValid = await bcrypt.compare(password, user.passwordHash);
    if (!isValid) return res.status(401).json({ message: 'Invalid credentials' });

    const token = generateAccessToken(user);
    return res.status(200).json({ message: 'Login successful', token, user });
  } catch (error) {
    return res.status(500).json({ message: 'Login failed', error: error.message });
  }
}

async function firebaseLogin(req, res) {
  try {
    // This endpoint is used when mobile app already authenticated with Firebase.
    const { email, name, firebaseUid, role = 'passenger', phone } = req.body;
    if (!email || !firebaseUid) {
      return res.status(400).json({ message: 'email and firebaseUid are required' });
    }

    let user = await User.findOne({
      $or: [{ email }, { firebaseUid }],
    });

    if (!user) {
      user = await User.create({
        email,
        name: name || email.split('@')[0],
        firebaseUid,
        role,
        phone,
      });
      if (role === 'driver') await Driver.create({ user: user._id });
    }

    const token = generateAccessToken(user);
    return res.status(200).json({ message: 'Firebase login successful', token, user });
  } catch (error) {
    return res.status(500).json({ message: 'Firebase login failed', error: error.message });
  }
}

async function logout(req, res) {
  // JWT logout is handled client-side by deleting token.
  return res.status(200).json({ message: 'Logout successful' });
}

async function registerDeviceToken(req, res) {
  try {
    const { deviceToken } = req.body;
    if (!deviceToken) return res.status(400).json({ message: 'deviceToken is required' });

    req.user.deviceToken = deviceToken;
    await req.user.save();
    return res.status(200).json({ message: 'Device token saved' });
  } catch (error) {
    return res.status(500).json({ message: 'Failed to save device token', error: error.message });
  }
}

module.exports = { signup, login, firebaseLogin, logout, registerDeviceToken };
