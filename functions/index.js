const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendLpgAlert = functions.database.ref("/LPG").onUpdate((change, context) => {
    const newValue = change.after.val();
    const previousValue = change.before.val();

    console.log(`LPG changed from ${previousValue} to ${newValue}`);

    if (newValue > 1000 && previousValue <= 1000) {
        const payload = {
            notification: {
                title: "High LPG Level Detected!",
                body: "LPG value has exceeded 1000 PPM. Please check immediately."
            }
        };

        return admin.messaging().sendToTopic("lpg_alerts", payload)
            .then(() => console.log("Notification sent successfully"))
            .catch((error) => console.error("Error sending notification:", error));
    }
    return null;
});