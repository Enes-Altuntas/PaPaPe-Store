import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(
                fontSize: 45.0,
                color: Colors.white,
                fontFamily: 'Armatic',
                fontWeight: FontWeight.bold),
            children: [
          TextSpan(text: 'Pa', style: TextStyle(color: Colors.red)),
          TextSpan(text: 'Pa', style: TextStyle(color: Colors.amber[600])),
          TextSpan(text: 'Pe', style: TextStyle(color: Colors.green[300]))
        ]));
  }
}
