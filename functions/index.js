const functions = require("firebase-functions");
const admin = require('firebase-admin');
const { firestore } = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.campaignCheckFinish = functions.pubsub.schedule('* * * * *').onRun(async (context) => {
    await db.collection('stores').get().then((value) => {
        value.docs.forEach(async (doc) => {
            await db.collection('stores/' + doc.id + '/campaigns').get().then((valueCamp) => {
                valueCamp.docs.forEach(async (campaign) => {
                    if (campaign.data().campaignFinish <= firestore.Timestamp.now() && campaign.data().campaignActive == true) {
                        await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignActive', false);
                        await db.doc('tokens/' + doc.id).get().then(async (token) => {
                            await admin.messaging().sendToDevice(token.data().tokenId, {
                                notification: {
                                    title: "Kampanyanız sona erdi !",
                                    body: 'Yayınlamış olduğunuz kampanya sona erdi. Haydi durmayın yeni bir kampanya yayınlayın !'
                                }
                            })
                        })
                    }
                })
            })
        })
    });
})

exports.campaignCheckStart = functions.pubsub.schedule('* * * * *').onRun(async (context) => {
    await db.collection('stores').get().then((value) => {
        value.docs.forEach(async (doc) => {
            await db.collection('stores/' + doc.id + '/campaigns').get().then((valueCamp) => {
                valueCamp.docs.forEach(async (campaign) => {
                    if (campaign.data().campaignStart <= firestore.Timestamp.now() && campaign.data().campaignActive == false) {
                        await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignActive', true);
                        await db.doc('tokens/' + doc.id).get().then(async (token) => {
                            await admin.messaging().sendToDevice(token.data().tokenId, {
                                notification: {
                                    title: "Kampanyanız başlıyor !",
                                    body: 'Yayınlamış olduğunuz kampanyanın saati geldi. Kampanyanız başlıyor !'
                                }
                            })
                        })
                    }
                })
            })
        })
    });
})

// exports.campaignCheck = functions.https.onRequest(async (req, res) => {
//     await db.collection('stores').get().then((value) => {
//         value.docs.forEach(async (doc) => {
//             await db.collection('stores/' + doc.id + '/campaigns').get().then((valueCamp) => {
//                 valueCamp.docs.forEach(async (campaign) => {
//                     if (campaign.data().campaignFinish <= firestore.Timestamp.now() && campaign.data().campaignActive == true) {
//                         await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignActive', false);
//                         console.log(campaign.data());
//                         await db.doc('tokens/' + doc.id).get().then((token) => {
//                             console.log(token.data().tokenId);
//                             admin.messaging().sendToDevice(token.data().tokenId, {
//                                 notification: {
//                                     title: "Kampanyanız sona erdi !",
//                                     body: 'Yayınlamış olduğunuz kampanya sona erdi. Haydi durmayın yeni bir kampanya yayınlayın !'
//                                 }
//                             })
//                         })
//                     }
//                 })
//             })
//         })
//     });
//     res.send('Başarılı !');
// })
