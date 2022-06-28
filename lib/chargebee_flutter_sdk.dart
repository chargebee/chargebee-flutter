
export 'src/chargebee.dart';

class Product {
  String id;
  String price;
  String title;
  Product(this.id, this.price, this.title);

  factory Product.fromJson(dynamic json) {
    print(json);
    print(json['productId'] as String);

    return Product(json['productId'] as String, json['productPrice'] as String,
        json['productTitle'] as String);
  }
}

class PurchaseResult {
  String subscriptionId;
  String status;
  PurchaseResult(this.subscriptionId, this.status);

  factory PurchaseResult.fromJson(dynamic json) {
    return PurchaseResult(json['id'] as String, json['status'] as String);
  }
}
