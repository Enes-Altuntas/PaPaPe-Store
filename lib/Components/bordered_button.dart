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
    return Container(
      width: MediaQuery.of(context).size.width * this.widthMultiplier,
      child: TextButton(
          child: Text(buttonText.toUpperCase(),
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  color: this.textColor,
                  fontWeight: FontWeight.bold)),
          style: ButtonStyle(
              padding:
                  MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
              foregroundColor: MaterialStateProperty.all<Color>(borderColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(width: 2, color: borderColor)))),
          onPressed: onPressed),
    );
  }
}
