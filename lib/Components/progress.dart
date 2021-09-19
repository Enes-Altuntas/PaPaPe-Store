import 'package:flutter/material.dart';

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
              color: Colors.amber[900],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Lütfen Bekleyiniz...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber[900], fontSize: 17.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
