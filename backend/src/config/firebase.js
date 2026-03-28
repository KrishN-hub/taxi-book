const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

function initFirebase() {
  if (admin.apps.length) return admin;

  const jsonPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS ||
    process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

  if (jsonPath) {
    const resolved = path.isAbsolute(jsonPath)
      ? jsonPath
      : path.resolve(process.cwd(), jsonPath);
    if (!fs.existsSync(resolved)) {
      console.warn(`Firebase Admin: credentials file not found: ${resolved}`);
      return null;
    }
    try {
      const raw = fs.readFileSync(resolved, 'utf8');
      const serviceAccount = JSON.parse(raw);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('Firebase Admin initialized (service account JSON)');
      return admin;
    } catch (err) {
      console.warn('Firebase Admin not initialized (invalid JSON file):', err.message);
      return null;
    }
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    console.warn('Firebase Admin not initialized (missing env vars).');
    return null;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey: privateKey.replace(/\\n/g, '\n'),
      }),
    });
    console.log('Firebase Admin initialized');
    return admin;
  } catch (err) {
    console.warn(
      'Firebase Admin not initialized (invalid credentials — check FIREBASE_PRIVATE_KEY or use a JSON file):',
      err.message
    );
    return null;
  }
}

module.exports = initFirebase;
