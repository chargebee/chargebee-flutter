
class Product {
  String id;
  String price;
  String title;
  String currencyCode;

  Product(this.id, this.price, this.title, this.currencyCode);

  factory Product.fromJson(dynamic json) {
    print(json);

    return Product(json['productId'] as String, json['productPrice'] as String,
        json['productTitle'] as String, json['currencyCode'] as String);
  }
}

class PurchaseResult {
  String subscriptionId;
  String planId;
  String status;
  PurchaseResult(this.subscriptionId, this.planId, this.status);

  factory PurchaseResult.fromJson(dynamic json) {
    return PurchaseResult(json['subscriptionId'] as String, json['planId'] as String, json['status'] as String);
  }
}

class Subscripton {
  String? subscriptionId;
  String? customerId;
  String? status;
  int? activatedAt;
  int? currentTermStart;
  int? currentTermEnd;
  String? planAmount;
  String? activatedAtString;
  String? currentTermEndString;
  String? currentTermStartString;

  Subscripton(
      {this.subscriptionId,
      this.customerId,
      this.status,
      this.activatedAt,
      this.currentTermStart,
      this.currentTermEnd,
      this.planAmount});

  Subscripton.fromJson(Map<String, dynamic> json) {
    subscriptionId = json['subscription_id'] as String;
    customerId = json['customer_id'] as String;
    status = json['status'] as String;
    activatedAt = json['activated_at'] as int;
    currentTermStart = json['current_term_start'] as int;
    currentTermEnd = json['current_term_end'] as int;
    planAmount = json['plan_amount']
        .toString(); /*Plan amount sometime we are getting double value sometime Int*/
  }
  Subscripton.fromJsonAndroid(Map<String, dynamic> json) {
    activatedAtString = json['activated_at'].toString();
    currentTermEndString = json['current_term_end'].toString();
    currentTermStartString = json['current_term_start'].toString();
    customerId = json['customer_id'] as String;
    planAmount = json['plan_amount'].toString();
    status = json['status'] as String;
    subscriptionId = json['subscription_id'] as String;
  }
}

class SubscriptonList {
  Subscripton? subscripton;

  SubscriptonList({this.subscripton});

  SubscriptonList.fromJson(dynamic json) {
    subscripton = json['cb_subscription'] != null
        ? new Subscripton.fromJson(json['cb_subscription'])
        : null;
  }
  SubscriptonList.fromJsonAndroid(dynamic json) {
    subscripton = json['cb_subscription'] != null
        ? new Subscripton.fromJsonAndroid(json['cb_subscription'])
        : null;
  }
}

class CBSubscriptionWrapper {
  List<Subscripton>? list;

  CBSubscriptionWrapper({this.list});

  CBSubscriptionWrapper.fromJson(List<dynamic> json) {
    print(json);
    List<Subscripton> subsArray = [];
    for (var value in json) {
      print(value);
      subsArray.add(Subscripton.fromJson(value));
    }

  }
}
