class UserModel {
  final String name;
  final String userId;
  final String iToken;
  final String token;
  final String storeId;
  final List favorites;
  final List campaignCodes;
  final List roles;

  UserModel(
      {this.userId,
      this.iToken,
      this.token,
      this.favorites,
      this.storeId,
      this.campaignCodes,
      this.roles,
      this.name});

  UserModel.fromFirestore(Map<String, dynamic> data)
      : userId = data['userId'],
        iToken = data['iToken'],
        token = data['token'],
        favorites = data['favorites'],
        storeId = data['storeId'],
        name = data['name'],
        roles = data['roles'],
        campaignCodes = data['campaignCodes'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'iToken': iToken,
      'token': token,
      'favorites': favorites,
      'storeId': storeId,
      'name': name,
      'roles': roles,
      'campaignCodes': campaignCodes,
    };
  }
}
