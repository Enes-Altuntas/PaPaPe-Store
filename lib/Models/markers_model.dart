class Markers {
  final bool hasCampaign;
  final String storeCategory;
  final String storeAltCategory;
  final double markerLatitude;
  final double markerLongtitude;
  final String markerTitle;
  final String markerId;
  final String storeId;

  Markers({
    this.hasCampaign,
    this.storeCategory,
    this.storeAltCategory,
    this.markerLatitude,
    this.markerId,
    this.markerLongtitude,
    this.markerTitle,
    this.storeId,
  });

  Markers.fromFirestore(Map<String, dynamic> data)
      : hasCampaign = data['hasCampaign'],
        storeCategory = data['storeCategory'],
        storeAltCategory = data['storeAltCategory'],
        markerLatitude = data['markerLatitude'],
        markerLongtitude = data['markerLongtitude'],
        markerId = data['markerId'],
        markerTitle = data['markerTitle'],
        storeId = data['storeId'];

  Map<String, dynamic> toMap() {
    return {
      'hasCampaign': hasCampaign,
      'storeCategory': storeCategory,
      'storeAltCategory': storeAltCategory,
      'markerLatitude': markerLatitude,
      'markerLongtitude': markerLongtitude,
      'markerId': markerId,
      'markerTitle': markerTitle,
      'storeId': storeId,
    };
  }
}
