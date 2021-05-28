class StoreAltCategory {
  final String storeCatId;
  final String storeAltCatId;
  final String storeAltCatName;
  final int storeAltCatRow;

  StoreAltCategory({
    this.storeCatId,
    this.storeAltCatId,
    this.storeAltCatName,
    this.storeAltCatRow,
  });

  StoreAltCategory.fromFirestore(Map<String, dynamic> data)
      : storeCatId = data['storeCatId'],
        storeAltCatId = data['storeAltCatId'],
        storeAltCatName = data['storeAltCatName'],
        storeAltCatRow = data['storeAltCatRow'];

  Map<String, dynamic> toMap() {
    return {
      'storeCatId': storeCatId,
      'storeAltCatId': storeAltCatId,
      'storeAltCatName': storeAltCatName,
      'storeAltCatRow': storeAltCatRow,
    };
  }
}
