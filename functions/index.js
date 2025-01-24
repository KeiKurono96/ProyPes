const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification to corresponding users when a new admin citation is created
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
          body: citation.text,
        },
        tokens: tokens,
        data: {
          notificationType: 'Citations'
        }
      };

      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`${response.successCount} notifications sent successfully`);
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
});

// Send notification to corresponding users when a new teacher citation is created
exports.sendClassroomBasedNotifications = functions.firestore
  .document('TCitations/{tcitationId}')
  .onCreate(async (snapshot, context) => {
    const tcitation = snapshot.data();
    const targetClass = tcitation.targetClass;

    // Get all users with the target role
    const usersSnapshot = await admin.firestore()
      .collection('Users')
      .where('tipo', '==', 'Apoderado')
      .where('aulas', 'array-contains', targetClass)
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
          title: tcitation.title,
          body: tcitation.text,
        },
        tokens: tokens,
        data: {
          notificationType: 'TCitations'
        }
      };

      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`${response.successCount} notifications sent successfully`);
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
});

// Send notification to corresponding user when a new Incidence is created
exports.sendIncidenceBasedNotifications = functions.firestore
  .document('Users/{userId}/Incidences/{incidenceId}')
  .onCreate(async (snapshot, context) => {
    const incidence = snapshot.data();

    const userId = context.params.userId;
    const receiverDoc = await admin.firestore().collection('Users')
      .doc(userId).get();

    const receiverData = receiverDoc.data();
    const token = receiverData.fcmToken;

    if(!token){
        console.log('No token for user, cannot send notification');
        return null;
    }

    // Send notification to the user
    const messageSent = {
      notification: {
        title: incidence.alumno,
        body: incidence.mensaje,
      },
      token: token,
      data: {
        notificationType: 'Incidences'
      }
    };

    try {
      const response = await admin.messaging().send(messageSent);
      console.log('Notification sent successfully: ', response);
    } catch (error) {
      console.error('Detailed error:', error);
      if(error.code && error.message) {
          console.error('Error code:', error.code);
          console.error('Error message:', error.message);
      }
      throw new Error('Failed to send notification');
    }
});

// Send notification to corresponding users when a new Homework is created
exports.sendHomeworkBasedNotifications = functions.firestore
  .document('Homework/{homeworkId}')
  .onCreate(async (snapshot, context) => {
    const homework = snapshot.data();
    const aula = homework.aula;

    // Get all users with the target role
    const usersSnapshot = await admin.firestore()
      .collection('Users')
      .where('tipo', '==', 'Apoderado')
      .where('aulas', 'array-contains', aula)
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
          title: homework.aula,
          body: homework.homework,
        },
        tokens: tokens,
        data: {
          notificationType: 'Homework'
        }
      };

      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`${response.successCount} notifications sent successfully`);
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
});

// Send notification to corresponding user when a new Grade is created
exports.sendGradeBasedNotifications = functions.firestore
  .document('Users/{userId}/StudentGrades/{gradeId}')
  .onCreate(async (snapshot, context) => {
    const newGrade = snapshot.data();

    const userId = context.params.userId;
    const receiverDoc = await admin.firestore().collection('Users')
      .doc(userId).get();

    const receiverData = receiverDoc.data();
    const token = receiverData.fcmToken;

    if(!token){
        console.log('No token for user, cannot send notification');
        return null;
    }

    // Send notification to the user
    const messageSent = {
      notification: {
        title: newGrade.alumno,
        body: newGrade.curso,
      },
      token: token,
      data: {
        notificationType: 'Grades'
      }
    };

    try {
      const response = await admin.messaging().send(messageSent);
      console.log('Notification sent successfully: ', response);
    } catch (error) {
      console.error('Detailed error:', error);
      if(error.code && error.message) {
          console.error('Error code:', error.code);
          console.error('Error message:', error.message);
      }
      throw new Error('Failed to send notification');
    }
});

// NO NOTIFICATION, function to delete a different user and it's subcollections (for admins)
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

    // Function to recursively delete subcollections
    async function deleteSubcollections(docRef) {
      const subcollections = await docRef.listCollections();
      for (const subcollection of subcollections) {
        const subcollectionDocs = await subcollection.get();
        const batch = admin.firestore().batch();
        subcollectionDocs.forEach((doc) => {
          batch.delete(doc.ref);
        });
        await batch.commit();
        // Recursively delete nested subcollections
        for (const doc of subcollectionDocs.docs) {
          await deleteSubcollections(doc.ref);
        }
      }
    }

    const userDocRef = admin.firestore().collection("Users").doc(uidToDelete);

    // Delete all subcollections
    await deleteSubcollections(userDocRef);

    // Delete the user from Firebase Authentication
    await admin.auth().deleteUser(uidToDelete);

    // Remove the user's Firestore document
    await userDocRef.delete();

    return { message: "User and all associated data deleted successfully." };
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

// NO NOTIFICATION, Function to update another user's password (for admins)
exports.updateUserPassword = functions.https.onCall(async (data, context) => {
  const callerUid = context.auth?.uid;
  if (!callerUid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const uid = data.uid;
  const newPassword = data.newPassword;

  if (!uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "UID to update must be provided."
    );
  }
  if (!newPassword) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Password to update must be provided."
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

    // 2. Update the user's password using the Admin SDK
    await admin.auth().updateUser(uid, { password: newPassword });
    console.log('Password updated successfully');
    return { success: true };
  } catch (error) {
    console.error('Error updating password:', error);
    throw new functions.https.HttpsError('internal', 'Password update failed');
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