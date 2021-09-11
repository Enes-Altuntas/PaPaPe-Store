import 'package:bulb/Models/wishes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final WishesModel wish;

  const CommentCard({Key key, this.wish}) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");

  String formatDate(Timestamp date) {
    var _date = DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
        .toLocal();
    return dateFormat.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shadowColor: Colors.black,
      elevation: 5.0,
      child: Container(
        decoration: BoxDecoration(color: Colors.amber[200]),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.wish.wishTitle,
              style: TextStyle(
                  color: Colors.amber[900],
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  fontSize: 17.0),
              textAlign: TextAlign.center,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text(
                  widget.wish.wishDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Roboto', color: Theme.of(context).hintColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                      'Oluşturulma Saati: ${formatDate(widget.wish.createdAt)}',
                      style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
