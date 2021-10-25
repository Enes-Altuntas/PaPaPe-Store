import 'package:flutter/material.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(
                fontSize: 45.0,
                fontFamily: 'Armatic',
                fontWeight: FontWeight.bold),
            children: [
          TextSpan(
              text: 'Pa',
              style: TextStyle(
                color: ColorConstants.instance.textOnColor,
              )),
          TextSpan(
              text: 'Pa',
              style: TextStyle(
                color: ColorConstants.instance.textOnColor,
              )),
          TextSpan(
              text: 'Pe',
              style: TextStyle(
                color: ColorConstants.instance.textOnColor,
              ))
        ]));
  }
}
