class StoreAltCategory {
  final String storeCatId;
  final String storeAltCatId;
  final String storeAltCatName;

  StoreAltCategory({
    this.storeCatId,
    this.storeAltCatId,
    this.storeAltCatName,
  });

  StoreAltCategory.fromFirestore(Map<String, dynamic> data)
      : storeCatId = data['storeCatId'],
        storeAltCatId = data['storeAltCatId'],
        storeAltCatName = data['storeAltCatName'];

  Map<String, dynamic> toMap() {
    return {
      'storeCatId': storeCatId,
      'storeAltCatId': storeAltCatId,
      'storeAltCatName': storeAltCatName,
    };
  }
}
