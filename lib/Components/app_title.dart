import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class AppTitleWidget extends StatelessWidget {
  const AppTitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: const TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
            children: [
          TextSpan(
              text: 'My',
              style: GoogleFonts.amaticSc(
                color: ColorConstants.instance.primaryColor,
              )),
          TextSpan(
              text: 'Rest',
              style: GoogleFonts.amaticSc(
                color: ColorConstants.instance.primaryColor,
              )),
          TextSpan(
              text: 'App',
              style: GoogleFonts.amaticSc(
                color: ColorConstants.instance.textGold,
              )),
        ]));
  }
}
