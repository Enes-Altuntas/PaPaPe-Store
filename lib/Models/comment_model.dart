import 'package:cloud_firestore/cloud_firestore.dart';

class Comments {
  final String reportDesc;
  final String reportTitle;
  final String reportId;
  final String reportUser;
  final Timestamp createdAt;

  Comments({
    this.reportDesc,
    this.reportTitle,
    this.reportId,
    this.reportUser,
    this.createdAt,
  });

  Comments.fromFirestore(Map<String, dynamic> data)
      : reportDesc = data['reportDesc'],
        reportTitle = data['reportTitle'],
        reportId = data['reportId'],
        reportUser = data['reportUser'],
        createdAt = data['createdAt'];

  Map<String, dynamic> toMap() {
    return {
      'reportDesc': reportDesc,
      'reportTitle': reportTitle,
      'reportId': reportId,
      'reportUser': reportUser,
      'createdAt': createdAt,
    };
  }
}
