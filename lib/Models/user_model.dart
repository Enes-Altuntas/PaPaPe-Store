class UserModel {
  final String userId;
  final String iToken;
  final List favorites;
  final List campaignCodes;

  UserModel({this.userId, this.iToken, this.favorites, this.campaignCodes});

  UserModel.fromFirestore(Map<String, dynamic> data)
      : userId = data['userId'],
        iToken = data['iToken'],
        favorites = data['favorites'],
        campaignCodes = data['campaignCodes'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'iToken': iToken,
      'favorites': favorites,
      'campaignCodes': campaignCodes,
    };
  }
}
