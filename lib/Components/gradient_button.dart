import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class GradientButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final String buttonText;
  final String fontFamily;
  final double fontSize;
  final double widthMultiplier;
  final Color start;
  final Color end;

  const GradientButton(
      {Key key,
      this.onPressed,
      this.icon,
      this.buttonText,
      this.fontFamily,
      this.start,
      this.end,
      this.fontSize,
      this.widthMultiplier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthMultiplier,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
              colors: [start, end],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter)),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: ColorConstants.instance.iconOnColor,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(buttonText,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: fontSize,
                      color: ColorConstants.instance.textOnColor,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
