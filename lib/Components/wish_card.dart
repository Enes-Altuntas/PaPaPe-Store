import 'package:papape_store/Constants/colors_constants.dart';
import 'package:papape_store/Models/wishes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final WishesModel wish;
  final Function onPressedCall;

  const CommentCard({Key key, this.wish, this.onPressedCall}) : super(key: key);

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
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            widget.wish.wishTitle,
            style: TextStyle(
                color: ColorConstants.instance.primaryColor,
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
                  fontFamily: 'Roboto',
                  color: ColorConstants.instance.hintColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                    'Oluşturulma Saati: ${formatDate(widget.wish.createdAt)}',
                    style: TextStyle(
                        color: ColorConstants.instance.hintColor,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: (widget.wish.wishUserPhone == null ||
                        widget.wish.wishUserPhone.isEmpty)
                    ? Text('İletişim No: Belirtilmemiş',
                        style: TextStyle(
                            color: ColorConstants.instance.hintColor,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0))
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: ColorConstants.instance.hintColor
                                    .withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0))),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 5.0, top: 5.0, left: 15.0, right: 15.0),
                          child: TextButton(
                              onPressed: widget.onPressedCall,
                              child: Text(
                                'İletişim No: +90${widget.wish.wishUserPhone}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstants.instance.activeColor,
                                ),
                              )),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
