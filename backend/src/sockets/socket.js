const { Server } = require('socket.io');
const Driver = require('../models/Driver');
const {
  passengerSocketMap,
  driverSocketMap,
} = require('../utils/socketState');

let ioInstance = null;

function initSocket(server) {
  ioInstance = new Server(server, {
    cors: {
      origin: '*',
    },
  });

  ioInstance.on('connection', (socket) => {
    socket.on('join:passenger', ({ userId }) => {
      if (userId) passengerSocketMap.set(String(userId), socket.id);
    });

    socket.on('join:driver', ({ driverId }) => {
      if (driverId) driverSocketMap.set(String(driverId), socket.id);
    });

    socket.on('driver:location:update', async ({ driverId, lng, lat, rideId }) => {
      if (!driverId || typeof lng !== 'number' || typeof lat !== 'number') return;

      // Persist latest location for nearby-driver queries.
      await Driver.findByIdAndUpdate(driverId, {
        location: { type: 'Point', coordinates: [lng, lat] },
      });

      if (rideId) {
        ioInstance.to(`ride:${rideId}`).emit('ride:tracking:update', {
          rideId,
          driverId,
          location: { lng, lat },
        });
      }
    });

    socket.on('ride:join', ({ rideId }) => {
      if (rideId) socket.join(`ride:${rideId}`);
    });

    socket.on('disconnect', () => {
      for (const [userId, socketId] of passengerSocketMap.entries()) {
        if (socketId === socket.id) passengerSocketMap.delete(userId);
      }
      for (const [driverId, socketId] of driverSocketMap.entries()) {
        if (socketId === socket.id) driverSocketMap.delete(driverId);
      }
    });
  });

  console.log('Socket.IO initialized');
  return ioInstance;
}

function getIo() {
  if (!ioInstance) throw new Error('Socket.IO not initialized');
  return ioInstance;
}

module.exports = { initSocket, getIo };
