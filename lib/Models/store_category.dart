class StoreCategory {
  final String storeCatId;
  final String storeCatName;

  StoreCategory({
    this.storeCatId,
    this.storeCatName,
  });

  StoreCategory.fromFirestore(Map<String, dynamic> data)
      : storeCatId = data['storeCatId'],
        storeCatName = data['storeCatName'];

  Map<String, dynamic> toMap() {
    return {
      'storeCatId': storeCatId,
      'storeCatName': storeCatName,
    };
  }
}
