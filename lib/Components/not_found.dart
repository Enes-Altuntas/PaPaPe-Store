import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotFound extends StatelessWidget {
  final IconData notFoundIcon;
  final Color notFoundIconColor;
  final String notFoundText;
  final Color notFoundTextColor;

  const NotFound(
      {Key key,
      this.notFoundIcon,
      this.notFoundIconColor,
      this.notFoundText,
      this.notFoundTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(notFoundIcon, size: 60.0, color: notFoundIconColor),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                notFoundText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: notFoundTextColor,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
