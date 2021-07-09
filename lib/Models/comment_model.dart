import 'package:cloud_firestore/cloud_firestore.dart';

class Comments {
  final String reportDesc;
  final String reportTitle;
  final String reportId;
  final Timestamp createdAt;

  Comments({
    this.reportDesc,
    this.reportTitle,
    this.reportId,
    this.createdAt,
  });

  Comments.fromFirestore(Map<String, dynamic> data)
      : reportDesc = data['reportDesc'],
        reportTitle = data['reportTitle'],
        reportId = data['reportId'],
        createdAt = data['createdAt'];

  Map<String, dynamic> toMap() {
    return {
      'reportDesc': reportDesc,
      'reportTitle': reportTitle,
      'reportId': reportId,
      'createdAt': createdAt,
    };
  }
}
