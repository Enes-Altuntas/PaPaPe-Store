import 'package:flutter/material.dart';
import 'package:papape_store/Constants/colors_constants.dart';

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ColorConstants.instance.primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Lütfen Bekleyiniz...',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.instance.primaryColor,
                    fontSize: 17.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
