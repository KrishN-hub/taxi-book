const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const User = require('../models/User');

async function verifyAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.split(' ')[1]
      : null;

    if (!token) {
      return res.status(401).json({ message: 'Missing authorization token' });
    }

    let payload = null;
    let mode = null;

    // 1) Try backend JWT first (issued after login/signup).
    try {
      payload = jwt.verify(token, process.env.JWT_SECRET);
      mode = 'jwt';
    } catch (err) {
      // 2) Fallback to Firebase ID token for direct mobile calls.
      if (admin.apps.length) {
        payload = await admin.auth().verifyIdToken(token);
        mode = 'firebase';
      }
    }

    if (!payload) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    if (mode === 'jwt') {
      const user = await User.findById(payload.userId);
      if (!user) return res.status(401).json({ message: 'User not found' });
      req.user = user;
      return next();
    }

    // Firebase token path
    const user = await User.findOne({
      $or: [{ firebaseUid: payload.uid }, { email: payload.email }],
    });
    if (!user) return res.status(401).json({ message: 'User not found' });

    req.user = user;
    return next();
  } catch (error) {
    return res.status(401).json({ message: 'Unauthorized', error: error.message });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden: insufficient role' });
    }
    return next();
  };
}

module.exports = { verifyAuth, requireRole };
