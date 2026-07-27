const { onDocumentWritten, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.onVersionUpdate = onDocumentUpdated(
  'app_config/{docId}',
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before || !after) return;

    const oldVersion = before.latestVersion;
    const newVersion = after.latestVersion;

    if (!newVersion || oldVersion === newVersion) return;

    const usersSnap = await getFirestore().collection('users').get();
    const tokens = usersSnap.docs
      .map((doc) => doc.data().fcmToken)
      .filter((t) => typeof t === 'string');

    if (tokens.length === 0) return;

    const messages = tokens.map((token) => ({
      token,
      notification: {
        title: 'Mise à jour disponible',
        body: `Version ${newVersion} disponible sur le Play Store.`,
      },
      android: { notification: { icon: 'ic_launcher', color: '#6750A4' } },
      data: {
        title: 'Mise à jour disponible',
        body: `Version ${newVersion} disponible sur le Play Store.`,
        type: 'update',
      },
    }));

    for (const msg of messages) {
      try {
        await getMessaging().send(msg);
      } catch (_) {}
    }
  },
);

exports.onTestMilestone = onDocumentWritten(
  'reviews/{reviewId}',
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!after) return;

    const wasValidated = before?.testValidated === true;
    const nowValidated = after.testValidated === true;

    if (wasValidated || !nowValidated) return;

    const userId = after.userId;
    if (!userId) return;

    const userDoc = await getFirestore().collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data();
    const token = userData?.fcmToken;
    const testsDone = userData?.testsDone ?? 0;

    if (!token) return;

    // Notification individuelle pour chaque validation
    try {
      await getMessaging().send({
        token,
        notification: {
          title: 'Test validé',
          body: `Un de tes tests a été validé. Continue comme ça !`,
        },
        android: { notification: { icon: 'ic_launcher', color: '#6750A4' } },
        data: {
          title: 'Test validé',
          body: `Un de tes tests a été validé. Continue comme ça !`,
          type: 'test_validated',
        },
      });
    } catch (_) {}

    // Notification palier tous les 10 tests
    if (testsDone > 0 && testsDone % 10 === 0) {
      try {
        await getMessaging().send({
          token,
          notification: {
            title: 'Félicitations !',
            body: `Tu as validé ${testsDone} tests. Continue comme ça !`,
          },
          android: { notification: { icon: 'ic_launcher', color: '#6750A4' } },
          data: {
            title: 'Félicitations !',
            body: `Tu as validé ${testsDone} tests. Continue comme ça !`,
            type: 'milestone',
          },
        });
      } catch (_) {}
    }
  },
);
