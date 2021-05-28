class Tokens {
  final String tokenId;
  final String tokenUser;

  Tokens({
    this.tokenId,
    this.tokenUser,
  });

  Tokens.fromFirestore(Map<String, dynamic> data)
      : tokenId = data['tokenId'],
        tokenUser = data['tokenUser'];

  Map<String, dynamic> toMap() {
    return {
      'tokenId': tokenId,
      'tokenUser': tokenUser,
    };
  }
}
