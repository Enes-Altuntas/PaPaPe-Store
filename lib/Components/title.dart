import 'package:flutter/material.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: const TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
            children: [
          TextSpan(
              text: 'My',
              style: TextStyle(
                fontFamily: 'Amatic',
                color: ColorConstants.instance.whiteContainer,
              )),
          TextSpan(
              text: 'Rest',
              style: TextStyle(
                fontFamily: 'Amatic',
                color: ColorConstants.instance.whiteContainer,
              )),
          TextSpan(
              text: 'App',
              style: TextStyle(
                fontFamily: 'Amatic',
                color: ColorConstants.instance.textGold,
              )),
        ]));
  }
}
