import 'package:flutter/foundation.dart';

class Product {
  late String id;
  late String title;
  late String currencyCode;
  late double price;
  late String priceString;
  late SubscriptionPeriod subscriptionPeriod;

  Product(this.id, this.price, this.priceString, this.title, this.currencyCode, this.subscriptionPeriod);

  factory Product.fromJson(dynamic json) {
    debugPrint('json: $json');
    final subscriptionPeriod = new SubscriptionPeriod.fromMap(json['subscriptionPeriod'] as Map<String, dynamic>);
    return Product(json['productId'] as String, json['productPrice'] as double, json['productPriceString'] as String,
        json['productTitle'] as String, json['currencyCode'] as String, subscriptionPeriod,);
  }

  @override
  String toString() => 'Product(id: $id, price: $price, priceString: $priceString title: $title, currencyCode: $currencyCode, subscriptionPeriod: $subscriptionPeriod)';
}

class SubscriptionPeriod {
  /// unit represent the duration of an interval, from a day up to a year.
  /// For example, unit value would be a month, year, day and week.
  late String unit;
  /// The number of units per subscription period.
  /// For example, if the number of units is 6, then the subscription period would be 6 months.
  late int numberOfUnits;

  SubscriptionPeriod.fromMap(Map<String, dynamic> map) {
    unit = map['periodUnit'].toString();
    numberOfUnits = map['numberOfUnits'] as int;
  }
}

class PurchaseResult {
  String subscriptionId;
  String planId;
  String status;

  PurchaseResult(this.subscriptionId, this.planId, this.status);

  factory PurchaseResult.fromJson(dynamic json) => PurchaseResult(json['subscriptionId'] as String,
        json['planId'] as String, json['status'] as String,);
  @override
  String toString() => 'PurchaseResult(subscriptionId: $subscriptionId, planId: $planId, status: $status)';
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
      this.planAmount,});

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
        ? Subscripton.fromJson(json['cb_subscription'])
        : null;
  }

  SubscriptonList.fromJsonAndroid(dynamic json) {
    subscripton = json['cb_subscription'] != null
        ? Subscripton.fromJsonAndroid(json['cb_subscription'])
        : null;
  }
}

class CBSubscriptionWrapper {
  List<Subscripton>? list;

  CBSubscriptionWrapper({this.list});

  CBSubscriptionWrapper.fromJson(List<dynamic> json) {
    final subsArray = <Subscripton>[];
    for (final value in json) {
      subsArray.add(Subscripton.fromJson(value));
    }
  }
}
