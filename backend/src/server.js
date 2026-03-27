require('dotenv').config();

const http = require('http');
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const connectDatabase = require('./config/database');
const initFirebase = require('./config/firebase');
const authRoutes = require('./routes/auth.routes');
const rideRoutes = require('./routes/ride.routes');
const paymentRoutes = require('./routes/payment.routes');
const { initSocket } = require('./sockets/socket');

const app = express();
const server = http.createServer(app);

// Core middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Health check
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'snail-taxi-backend' });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/rides', rideRoutes);
app.use('/api/payments', paymentRoutes);

// Initialize Firebase Admin and sockets
initFirebase();
initSocket(server);

// Start server only after DB connection
const PORT = process.env.PORT || 5000;
connectDatabase()
  .then(() => {
    server.listen(PORT, () => {
      // Keep startup message clear for local dev and deployment logs.
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Failed to start server:', error.message);
    process.exit(1);
  });
