import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('PaPaPe',
        style: TextStyle(
            fontSize: 45.0,
            color: Colors.white,
            fontFamily: 'Armatic',
            fontWeight: FontWeight.bold));
  }
}
