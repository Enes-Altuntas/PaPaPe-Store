class UserModel {
  final String userId;
  final String token;
  final List favorites;

  UserModel({this.userId, this.token, this.favorites});

  UserModel.fromFirestore(Map<String, dynamic> data)
      : userId = data['userId'],
        token = data['token'],
        favorites = data['favorites'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'token': token,
      'favorites': favorites,
    };
  }
}
