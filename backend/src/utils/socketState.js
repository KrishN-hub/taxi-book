// Simple in-memory maps for active socket connections.
// In production at scale, replace with Redis-based adapter/state.
const passengerSocketMap = new Map(); // userId -> socketId
const driverSocketMap = new Map(); // driverId -> socketId

module.exports = { passengerSocketMap, driverSocketMap };
