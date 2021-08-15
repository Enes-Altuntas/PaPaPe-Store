import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotFound extends StatelessWidget {
  final IconData notFoundIcon;
  final double notFoundIconSize;
  final Color notFoundIconColor;
  final String notFoundText;
  final double notFoundTextSize;
  final Color notFoundTextColor;

  const NotFound(
      {Key key,
      this.notFoundIcon,
      this.notFoundIconColor,
      this.notFoundIconSize,
      this.notFoundText,
      this.notFoundTextColor,
      this.notFoundTextSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(this.notFoundIcon,
                size: this.notFoundIconSize, color: this.notFoundIconColor),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                this.notFoundText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Bebas',
                    fontSize: this.notFoundTextSize,
                    color: this.notFoundTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
