const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.myFunction = functions.firestore
  .document("chat/{messageId}")
  .onCreate((snapshot, context) => {
    return admin.messaging().sendToTopic("chat", {
      // Sending a notification message.
      notification: {
        title: snapshot.data()["name"],
        body: snapshot.data()["message"],
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    });
  });