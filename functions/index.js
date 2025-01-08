const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification to corresponding users when a new citation is created
exports.sendRoleBasedNotifications = functions.firestore
  .document('Citations/{citationId}')
  .onCreate(async (snapshot, context) => {
    const citation = snapshot.data();
    const targetRole = citation.targetRole;

    // Get all users with the target role
    const usersSnapshot = await admin.firestore()
      .collection('Users')
      .where('tipo', '==', targetRole)
      .get();

    const tokens = [];
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    // Send notifications to all tokens
    if (tokens.length > 0) {
      const message = {
        notification: {
          title: citation.title,
          body: citation.message,
        },
        tokens: tokens,
      };

      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`${response.successCount} notifications sent successfully`);
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
});

// NO NOTIFICATION, function to delete a different user (for admins)
exports.deleteUser = functions.https.onCall(async (data, context) => {
  const callerUid = context.auth?.uid;
  if (!callerUid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const { uidToDelete } = data;
  if (!uidToDelete) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "UID to delete must be provided."
    );
  }

  try {
    // Fetch the caller's role
    const callerDoc = await admin.firestore().collection("Users").doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.data().tipo !== "Administrador") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete users."
      );
    }

    // Delete the user from Firebase Authentication
    await admin.auth().deleteUser(uidToDelete);

    // Remove the user's Firestore document
    await admin.firestore().collection("Users").doc(uidToDelete).delete();

    return { message: "User deleted successfully." };
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      "Error deleting user: " + error.message
    );
  }
});

// NO NOTIFICATION, Function to update another user's email (for admins)
exports.updateUserEmail = functions.https.onCall(async (data, context) => {
  const callerUid = context.auth?.uid;
  if (!callerUid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const uid = data.uid; // UID of the user to update
  const newEmail = data.newEmail;

  if (!uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "UID to update must be provided."
    );
  }
  if (!newEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Email to update must be provided."
    );
  }

  try {
    // 1. Fetch the caller's role
    const callerDoc = await admin.firestore().collection("Users").doc(callerUid).get();
    if (!callerDoc.exists || callerDoc.data().tipo !== "Administrador") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete users."
      );
    }

    // 2. Update the user's email using the Admin SDK
    await admin.auth().updateUser(uid, {
      email: newEmail,
      emailVerified: false, // Important: Reset email verification
    });

    // 3. Update firestore email
    await admin.firestore().collection("Users").doc(uid).update({"email": newEmail});

    return { message: "User email updated successfully." };
  } catch (error) {
    console.error("Error updating user email:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});


// Send notification when a new message is created in our firestore
// exports.sendNotificationOnMessage = functions.firestore
// .document('chat_rooms/{chatRoomId}/messages/{messageId}')
// .onCreate(async (snapshot, context) => {
//     const message = snapshot.data();

//     try{
//         const receiverDoc = await admin.firestore().collection('Users')
//         .doc(message.receiverId).get();
//         if(!receiverDoc.exists) {
//             console.log('No such receiver!');
//             return null;
//         }

//         const receiverData = receiverDoc.data();
//         const token = receiverData.fcmToken;

//         if(!token){
//             console.log('No token for user, cannot send notification');
//             return null;
//         }

//         // Updated message payload for 'send' method
//         const messagePayload = {
//             token: token,
//             notification: {
//                 title: message.senderEmail,
//                 body: message.message,
//             },
//             android: {
//                 notification: {
//                     clickAction: 'FLUTTER_NOTIFICATION_CLICK'
//                 }
//             },
//             apns: {
//                 payload: {
//                     aps:{
//                         category: 'FLUTTER_NOTIFICATION_CLICK'
//                     }
//                 }
//             }
//         };

//         // Send the notification
//         const response = await admin.messaging().send(messagePayload);
//         console.log('Notification sent successfully: ', response);
//         return response;
//     } catch (error) {
//         console.error('Detailed error:', error);
//         if(error.code && error.message) {
//             console.error('Error code:', error.code);
//             console.error('Error message:', error.message);
//         }
//         throw new Error('Failed to send notification');
//     }
// })