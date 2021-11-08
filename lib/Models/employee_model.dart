class EmployeeModel {
  final String name;
  final String storeId;
  final String phone;
  final String employeeId;

  EmployeeModel({this.name, this.storeId, this.phone, this.employeeId});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'storeId': storeId,
      'phone': phone,
      'employeeId': employeeId
    };
  }

  EmployeeModel.fromFirestore(Map<String, dynamic> firestore)
      : name = firestore['name'],
        storeId = firestore['storeId'],
        phone = firestore['phone'],
        employeeId = firestore['employeeId'];
}
