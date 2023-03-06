/* eslint-disable prefer-const */
/* eslint-disable max-len */
/* eslint-disable no-unused-vars */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.updateDocumentOnSpecificDate = functions.https.onCreate((req, res) => {
  const date = new Date(req.body.date + 'T00:00:00.000Z');
  const now = new Date();
  const docId = req.body.document_id;
  if (now.getTime() === date.getTime()) {
    firebase.firestore().collection('jobs').doc(docId).update({
      'isStarted': true
    })
      .then(() => {
        res.status(200).send('Document updated successfully');
      })
      .catch((error) => {
        console.error(error);
        res.status(500).send(error);
      });
  } else {
    res.status(200).send('The current date does not match the specified date');
  }
});

exports.listFruit = functions.https.onCall(() => {
  return ["Apple", "Banana", "Cherry", "Date", "Fig", "Grapes"];
});

exports.getLastMessage = functions.firestore.document("/chats/{chatID}/chats/{docID}").onCreate(async (snap, context) => {
  const newValue = snap.data();

  let chatID = context.params.chatID;
  let docID = context.params.docID;

  let friendsDoc = await db.collection("chats").doc(chatID).get();

  let careTakerID = friendsDoc.data()["careTakerID"];
  let userID = friendsDoc.data()["userID"];

  if (userID == newValue["sentBy"]) {
    await db.collection("users").doc(careTakerID).collection("messages").doc(careTakerID).update({
      "lastMessage": newValue["message"],
      "lastMessageBy": newValue["sentBy"],
      "lastMessageOn": newValue["sentOn"],
    });
    await db.collection("careTakers").doc(userID).collection("messages").doc(userID).update({
      "lastMessage": newValue["message"],
      "lastMessageBy": newValue["sentBy"],
      "lastMessageOn": newValue["sentOn"],
      "unreadCount": admin.firestore.FieldValue.increment(1),
    });
  } else {
    await db.collection("careTakers").doc(userID).collection("messages").doc(userID).update({
      "lastMessage": newValue["message"],
      "lastMessageBy": newValue["sentBy"],
      "lastMessageOn": newValue["sentOn"],
    });
    await db.collection("users").doc(careTakerID).collection("messages").doc(careTakerID).update({
      "lastMessage": newValue["message"],
      "lastMessageBy": newValue["sentBy"],
      "lastMessageOn": newValue["sentOn"],
      "unreadCount": admin.firestore.FieldValue.increment(1),
    });
  }

  return null;
});

exports.listFruit = functions.https.onCall((data, context) => {
  return ["Apple", "Banana", "Cherry", "Date", "Fig", "Grapes"]
});

