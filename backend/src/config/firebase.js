const admin = require('firebase-admin');

function initFirebase() {
  if (admin.apps.length) return admin;

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  // Allow startup without Firebase in early local development.
  if (!projectId || !clientEmail || !privateKey) {
    console.warn('Firebase Admin not initialized (missing env vars).');
    return null;
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey: privateKey.replace(/\\n/g, '\n'),
    }),
  });

  console.log('Firebase Admin initialized');
  return admin;
}

module.exports = initFirebase;
