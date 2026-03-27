const jwt = require('jsonwebtoken');

function generateAccessToken(user) {
  return jwt.sign(
    { userId: user._id.toString(), role: user.role, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

module.exports = { generateAccessToken };
