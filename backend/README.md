# Snail Taxi App - Node.js Backend (Step 2)

Backend stack from PRD:
- Node.js + Express
- MongoDB Atlas (Mongoose)
- Socket.IO for realtime ride flow
- Firebase Admin (token verification ready)
- Stripe/Razorpay sandbox payment APIs

## Folder Structure

```text
backend/
  package.json
  .env.example
  src/
    server.js
    config/
      database.js
      firebase.js
    controllers/
      auth.controller.js
      ride.controller.js
      payment.controller.js
    models/
      User.js
      Driver.js
      Ride.js
      Payment.js
    middlewares/
      auth.middleware.js
    routes/
      auth.routes.js
      ride.routes.js
      payment.routes.js
    services/
      payment.service.js
    sockets/
      socket.js
    utils/
      token.js
      socketState.js
```

## Setup

1. Install dependencies:
   ```bash
   cd backend
   npm install
   ```
2. Create env file:
   ```bash
   copy .env.example .env
   ```
3. Fill `.env` values:
   - MongoDB Atlas URI
   - JWT secret
   - Stripe and/or Razorpay sandbox keys
   - Firebase Admin credentials
4. Start server:
   ```bash
   npm run dev
   ```

## Core API Endpoints

- `POST /api/auth/signup`
- `POST /api/auth/login`
- `POST /api/auth/firebase-login`
- `POST /api/auth/logout`

- `POST /api/rides/request`
- `GET /api/rides/nearby`
- `POST /api/rides/accept`
- `POST /api/rides/complete`
- `GET /api/rides/history`
- `POST /api/rides/rate`

- `POST /api/payments/create`
- `POST /api/payments/confirm`

## Realtime Socket Events

- `join:passenger` -> register passenger socket
- `join:driver` -> register driver socket
- `ride:request:new` -> sent to nearby drivers
- `ride:accepted` -> sent to passenger when driver accepts
- `ride:join` -> join ride room (`ride:{rideId}`)
- `driver:location:update` -> emits `ride:tracking:update`
- `ride:status:updated` -> accepted/completed updates

## Notes

- This is sandbox-ready and PRD-aligned.
- For production scale, use Redis adapter for Socket.IO and background jobs for notifications/webhooks.
