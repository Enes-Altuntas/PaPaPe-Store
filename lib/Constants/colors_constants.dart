import 'dart:ui';

class ColorConstants {
  static ColorConstants instance = ColorConstants._init();

  ColorConstants._init();

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  final primaryColor = fromHex('#2E4D2E');
  final secondaryColor = fromHex('#5C995D');
  final facebookColor = fromHex('#1877F2');
  final twitterColor = fromHex('#1D9BF0');
  final textOnColor = fromHex('#ffffff');
  final textGold = fromHex('#f6ab13');
  final iconOnColor = fromHex('#ffffff');
  final whiteContainer = fromHex('#ffffff');
  final googleRedColor = fromHex('#C62828');
  final signBackButtonPrimary = fromHex('#B71C1C');
  final signBackButtonSecondary = fromHex('#6A1010');
  final hintColor = fromHex('#555555');
  final activeColor = fromHex('#2C6D2F');
  final waitingColor = fromHex('#ED9F00');
  final inactiveColor = fromHex('#B71C1C');
  final campaignCardInsideColor = fromHex('#FFE082');
  final buttonDarkGold = fromHex('#dd9911');
  final buttonLightColor = fromHex('#f7bb42');
}
