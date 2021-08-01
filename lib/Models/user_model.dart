class UserModel {
  final String userId;
  final String token;

  UserModel({
    this.userId,
    this.token,
  });

  UserModel.fromFirestore(Map<String, dynamic> data)
      : userId = data['userId'],
        token = data['token'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'token': token,
    };
  }
}
