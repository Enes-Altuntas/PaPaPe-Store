import 'package:flutter/material.dart';

class BorderedButton extends StatelessWidget {
  final String buttonText;
  final Function onPressed;
  final double widthMultiplier;
  final Color borderColor;
  final Color textColor;

  const BorderedButton(
      {Key key,
      this.buttonText,
      this.onPressed,
      this.widthMultiplier,
      this.borderColor,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthMultiplier,
      child: TextButton(
          child: Text(buttonText.toUpperCase(),
              style: TextStyle(
                  fontSize: 16, color: textColor, fontWeight: FontWeight.bold)),
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.all(15)),
              foregroundColor: MaterialStateProperty.all<Color>(borderColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(width: 3, color: borderColor)))),
          onPressed: onPressed),
    );
  }
}
