import 'dart:io';

class Product {
  final String productDesc;
  final String productName;
  final int productPrice;
  final String productId;
  final String productCatId;
  String productPicRef;
  File productLocalImage;

  Product(
      {this.productDesc,
      this.productName,
      this.productPrice,
      this.productId,
      this.productCatId,
      this.productPicRef,
      this.productLocalImage});

  Product.fromFirestore(Map<String, dynamic> data)
      : productDesc = data['productDesc'],
        productName = data['productName'],
        productPrice = data['productPrice'],
        productId = data['productId'],
        productCatId = data['productCatId'],
        productPicRef = data['productPicRef'];

  Map<String, dynamic> toMap() {
    return {
      'productDesc': productDesc,
      'productName': productName,
      'productPrice': productPrice,
      'productId': productId,
      'productCatId': productCatId,
      'productPicRef': productPicRef,
    };
  }
}
