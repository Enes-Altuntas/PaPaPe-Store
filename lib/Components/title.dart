import 'package:flutter/material.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: const TextStyle(
                fontSize: 50.0,
                fontFamily: 'Armatic',
                fontWeight: FontWeight.bold),
            children: [
          TextSpan(
              text: 'Pa',
              style: TextStyle(
                color: ColorConstants.instance.inactiveColor,
              )),
          TextSpan(
              text: 'Pa',
              style: TextStyle(
                color: ColorConstants.instance.waitingColor,
              )),
          TextSpan(
              text: 'Pe',
              style: TextStyle(
                color: ColorConstants.instance.activeColor,
              ))
        ]));
  }
}
