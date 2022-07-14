import 'dart:convert';

import 'dart:ffi';

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
  String? planAmount;

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
}

class SubscriptonList {
  Subscripton? subscripton;

  SubscriptonList({this.subscripton});

  SubscriptonList.fromJson(dynamic json) {
    subscripton = json['cb_subscription'] != null
        ? new Subscripton.fromJson(json['cb_subscription'])
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

    // if (json['cb_subscription'] != null) {
    //   list = <Subscripton>[];
    //   json['cb_subscription'].forEach((v) {
    //     list!.add(new Subscripton.fromJson(v));
    //   });
    // }
  }
}


  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   if (this.subscripton != null) {
  //     data['cb_subscription'] = this.subscripton!.toJson();
  //   }
  //   return data;
  // }

