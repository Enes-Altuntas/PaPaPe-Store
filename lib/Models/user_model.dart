class UserModel {
  final String userId;
  final String token;
  final List favorites;
  final List campaignCodes;

  UserModel({this.userId, this.token, this.favorites, this.campaignCodes});

  UserModel.fromFirestore(Map<String, dynamic> data)
      : userId = data['userId'],
        token = data['token'],
        favorites = data['favorites'],
        campaignCodes = data['campaignCodes'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'token': token,
      'favorites': favorites,
      'campaignCodes': campaignCodes,
    };
  }
}
