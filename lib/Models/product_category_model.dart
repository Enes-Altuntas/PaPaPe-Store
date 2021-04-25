class ProductCategory {
  final String categoryId;
  final String categoryName;
  final int categoryRow;

  ProductCategory({
    this.categoryId,
    this.categoryName,
    this.categoryRow,
  });

  ProductCategory.fromFirestore(Map<String, dynamic> data)
      : categoryId = data['categoryId'],
        categoryName = data['categoryName'],
        categoryRow = data['categoryRow'];

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryRow': categoryRow,
    };
  }
}
