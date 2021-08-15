import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GradientButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final String buttonText;
  final String fontFamily;
  final double fontSize;
  final double widthMultiplier;

  const GradientButton(
      {Key key,
      this.onPressed,
      this.icon,
      this.buttonText,
      this.fontFamily,
      this.fontSize,
      this.widthMultiplier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * this.widthMultiplier,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor
          ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
      child: TextButton(
        onPressed: this.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              this.icon,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(this.buttonText,
                  style: TextStyle(
                      fontFamily: this.fontFamily,
                      fontSize: this.fontSize,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
