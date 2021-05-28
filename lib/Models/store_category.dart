class StoreCategory {
  final String storeCatId;
  final String storeCatName;
  final int storeCatRow;

  StoreCategory({
    this.storeCatId,
    this.storeCatName,
    this.storeCatRow,
  });

  StoreCategory.fromFirestore(Map<String, dynamic> data)
      : storeCatId = data['storeCatId'],
        storeCatName = data['storeCatName'],
        storeCatRow = data['storeCatRow'];

  Map<String, dynamic> toMap() {
    return {
      'storeCatId': storeCatId,
      'storeCatName': storeCatName,
      'storeCatRow': storeCatRow,
    };
  }
}
