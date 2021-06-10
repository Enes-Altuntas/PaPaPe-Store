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
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: StreamBuilder<List<Comments>>(
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                color: Colors.white,
                                shadowColor: Colors.black,
                                elevation: 5.0,
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      snapshot.data[index].reportTitle,
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          snapshot.data[index].reportDesc,
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).hintColor),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                              'Puan: ${snapshot.data[index].reportScore.toString()}',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0)),
                                        ),
                                      ],
                                    ),
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
                  backgroundColor: Colors.white,
                ));
        },
      ),
    );
  }
}
