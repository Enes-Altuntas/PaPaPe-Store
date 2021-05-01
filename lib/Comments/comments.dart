import 'package:bulovva_store/Models/comment_model.dart';
import 'package:bulovva_store/Services/firestore_service.dart';
import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  Reports({Key key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Comments>>(
        stream: FirestoreService().getReports(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.active)
              ? (snapshot.hasData == true)
                  ? (snapshot.data.length > 0)
                      ? ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Theme.of(context).primaryColor,
                                shadowColor: Theme.of(context).primaryColor,
                                elevation: 10.0,
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      snapshot.data[index].reportTitle,
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Text(
                                      snapshot.data[index].reportDesc,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Puan: ${snapshot.data[index].reportScore.toString()}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_late_outlined,
                                size: 100.0,
                                color: Theme.of(context).primaryColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Text(
                                    'Henüz işletmeniz adına yapılmış bir yorum bulunmamaktadır !',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 100.0,
                            color: Theme.of(context).primaryColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                'Henüz işletmeniz adına yapılmış bir yorum bulunmamaktadır !',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25.0,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                ));
        },
      ),
    );
  }
}
