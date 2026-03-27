const admin = require('firebase-admin');

async function sendPushNotification({ token, title, body, data = {} }) {
  if (!token || !admin.apps.length) return;

  await admin.messaging().send({
    token,
    notification: { title, body },
    data,
  });
}

module.exports = { sendPushNotification };
