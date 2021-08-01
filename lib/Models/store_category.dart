class StoreCategory {
  final String storeCatId;
  final String storeCatName;
  final String storeCatPicRef;
  final String storeShort;
  final int storeCatRow;
  bool checked = false;

  StoreCategory({
    this.storeCatId,
    this.storeCatName,
    this.storeCatPicRef,
    this.storeShort,
    this.storeCatRow,
  });

  StoreCategory.fromFirestore(Map<String, dynamic> data)
      : storeCatId = data['storeCatId'],
        storeCatName = data['storeCatName'],
        storeCatPicRef = data['storeCatPicRef'],
        storeShort = data['storeShort'],
        storeCatRow = data['storeCatRow'];

  Map<String, dynamic> toMap() {
    return {
      'storeCatId': storeCatId,
      'storeCatName': storeCatName,
      'storeCatPicRef': storeCatPicRef,
      'storeShort': storeShort,
      'storeCatRow': storeCatRow,
    };
  }
}
