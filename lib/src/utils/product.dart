class Product {
  String id;
  String price;
  String title;
  Product(this.id, this.price, this.title);

  factory Product.fromJson(dynamic json) {
    print(json);

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

class Subscripton {
  String? subscriptionId;
  String? customerId;
  String? status;
  int? activatedAt;
  int? currentTermStart;
  int? currentTermEnd;
  int? planAmount;

  Subscripton(
      {this.subscriptionId,
      this.customerId,
      this.status,
      this.activatedAt,
      this.currentTermStart,
      this.currentTermEnd,
      this.planAmount});

  Subscripton.fromJson(dynamic json) {
    print(json);

    subscriptionId = json['subscription_id'];
    customerId = json['customer_id'];
    status = json['status'];
    activatedAt = json['activated_at'];
    currentTermStart = json['current_term_start'];
    currentTermEnd = json['current_term_end'];
    planAmount = json['plan_amount'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['subscription_id'] = this.subscriptionId;
  //   data['customer_id'] = this.customerId;
  //   data['status'] = this.status;
  //   data['activated_at'] = this.activatedAt;
  //   data['current_term_start'] = this.currentTermStart;
  //   data['current_term_end'] = this.currentTermEnd;
  //   data['plan_amount'] = this.planAmount;
  //   return data;
  // }
}

class SubscriptonList {
  Subscripton? subscripton;

  SubscriptonList({this.subscripton});

  SubscriptonList.fromJson(dynamic json) {
    print(json);

    subscripton = json['cb_subscription'] != null
        ? new Subscripton.fromJson(json['cb_subscription'])
        : null;
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   if (this.subscripton != null) {
  //     data['cb_subscription'] = this.subscripton!.toJson();
  //   }
  //   return data;
  // }
}
