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
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(notFoundIcon,
                size: notFoundIconSize, color: notFoundIconColor),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                notFoundText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Amatic',
                    fontSize: notFoundTextSize,
                    fontWeight: FontWeight.bold,
                    color: notFoundTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
