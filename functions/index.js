const functions = require("firebase-functions");
const admin = require('firebase-admin');
const { firestore } = require("firebase-admin");
var serviceAccount = require("./bulovva-7fdb8-firebase-adminsdk-o4lrw-6ee1829186.json");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();

exports.campaignStartJob = functions.pubsub.schedule('* * * * *').onRun(async (context) => {
    await db.collection('stores').get().then((value) => {
        value.docs.forEach(async (doc) => {
            var query = db.collection('stores/' + doc.id + '/campaigns')
            query = query.where('automatedStart', '==', false)
            query = query.where('campaignStart', '<=', firestore.Timestamp.now())
            query = query.where('campaignStatus', '==', 'wait')
            await query.get().then((valueCamp) => {
                valueCamp.docs.forEach(async (campaign) => {
                    await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignStatus', 'active', 'automatedStart', true);
                    await db.doc('markers/' + doc.id).update('hasCampaign', true);
                    await db.doc('tokens/' + doc.id).get().then(async (token) => {
                        await admin.messaging().sendToDevice(token.data().tokenId, {
                            notification: {
                                title: "Kampanyanız başlıyor !",
                                body: 'Hazır olun çünkü kampanyanız başlıyor !'
                            }
                        })
                    })
                })
            })
        })
    });
})

exports.campaignStopJob = functions.pubsub.schedule('* * * * *').onRun(async (context) => {
    await db.collection('stores').get().then((value) => {
        value.docs.forEach(async (doc) => {
            var query = db.collection('stores/' + doc.id + '/campaigns')
            query = query.where('automatedStop', '==', false)
            query = query.where('campaignFinish', '<=', firestore.Timestamp.now())
            query = query.where('campaignStatus', '==', 'active')
            await query.get().then((valueCamp) => {
                valueCamp.docs.forEach(async (campaign) => {
                    await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignStatus', 'inactive', 'automatedStop', true);
                    await db.doc('markers/' + doc.id).update('hasCampaign', false);
                    await db.doc('tokens/' + doc.id).get().then(async (token) => {
                        await admin.messaging().sendToDevice(token.data().tokenId, {
                            notification: {
                                title: "Kampanyanız sona erdi !",
                                body: 'Haydi durmayın tekrar kampanya yayınlamanın tam zamanı !'
                            }
                        })
                    })
                })
            })
        })
    });
})

exports.campaignStartHttp = functions.https.onRequest(async (req, res) => {
    await db.collection('stores').get().then((value) => {
        value.docs.forEach(async (doc) => {
            var query = db.collection('stores/' + doc.id + '/campaigns')
            query = query.where('automatedStart', '==', false)
            query = query.where('campaignStart', '<=', firestore.Timestamp.now())
            query = query.where('campaignStatus', '==', 'wait')
            await query.get().then((valueCamp) => {
                valueCamp.docs.forEach(async (campaign) => {
                    await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignStatus', 'active', 'automatedStart', true);
                    await db.doc('markers/' + doc.id).update('hasCampaign', true);
                    await db.doc('tokens/' + doc.id).get().then(async (token) => {
                        await admin.messaging().sendToDevice(token.data().tokenId, {
                            notification: {
                                title: "Kampanyanız başlıyor !",
                                body: 'Hazır olun çünkü kampanyanız başlıyor !'
                            }
                        })
                    })
                })
            })
        })
    });
    res.send('Başarılı !');
})

exports.campaignStopHttp = functions.https.onRequest(async (req, res) => {
    await db.collection('stores').get().then((value) => {
        value.docs.forEach(async (doc) => {
            var query = db.collection('stores/' + doc.id + '/campaigns')
            query = query.where('automatedStop', '==', false)
            query = query.where('campaignFinish', '<=', firestore.Timestamp.now())
            query = query.where('campaignStatus', '==', 'active')
            await query.get().then((valueCamp) => {
                valueCamp.docs.forEach(async (campaign) => {
                    await db.doc('stores/' + doc.id + '/campaigns/' + campaign.id).update('campaignStatus', 'inactive', 'automatedStop', true);
                    await db.doc('markers/' + doc.id).update('hasCampaign', false);
                    await db.doc('tokens/' + doc.id).get().then(async (token) => {
                        await admin.messaging().sendToDevice(token.data().tokenId, {
                            notification: {
                                title: "Kampanyanız sona erdi !",
                                body: 'Haydi durmayın tekrar kampanya yayınlamanın tam zamanı!'
                            }
                        })
                    })
                })
            })
        })
    });
    res.send('Başarılı !');
});

exports.commentCreate = functions.firestore.document('stores/{storeId}/reports/{reportId}').onCreate(async (snapshot, context) => {
    const { storeId } = context.params;
    await db.doc('tokens/' + storeId).get().then(async (token) => {
        await admin.messaging().sendToDevice(token.data().tokenId, {
            notification: {
                title: "Yeni Yorum Geldi !",
                body: 'Sanırım birileri size bir şey söylemek istiyor.'
            }
        })
    })
});
