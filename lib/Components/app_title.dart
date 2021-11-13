import 'package:flutter/material.dart';

class AppTitleWidget extends StatelessWidget {
  const AppTitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/title.png',
      height: 50.0,
    );
  }
}
