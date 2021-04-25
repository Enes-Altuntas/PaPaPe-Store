class Markers {
  final bool hasCampaign;
  final String storeCategory;
  final String markerLatitude;
  final String markerLongtitude;
  final String markerTitle;
  final String storeId;

  Markers({
    this.hasCampaign,
    this.storeCategory,
    this.markerLatitude,
    this.markerLongtitude,
    this.markerTitle,
    this.storeId,
  });

  Markers.fromFirestore(Map<String, dynamic> data)
      : hasCampaign = data['hasCampaign'],
        storeCategory = data['storeCategory'],
        markerLatitude = data['markerLatitude'],
        markerLongtitude = data['markerLongtitude'],
        markerTitle = data['markerTitle'],
        storeId = data['storeId'];

  Map<String, dynamic> toMap() {
    return {
      'hasCampaign': hasCampaign,
      'storeCategory': storeCategory,
      'markerLatitude': markerLatitude,
      'markerLongtitude': markerLongtitude,
      'markerTitle': markerTitle,
      'storeId': storeId,
    };
  }
}
