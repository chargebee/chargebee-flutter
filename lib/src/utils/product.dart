import 'dart:convert';
import 'package:flutter/foundation.dart';

class Product {
  String id = "";
  String title = "";
  String currencyCode = "";
  double price = 0;
  SKDetails? skDetails;
  SubscriptionPeriod? subscriptionPeriod;

  Product.jsonForIOS(String id,
      double price,
      String title,
      String currencyCode,
      SubscriptionPeriod subscriptionPeriod){
    this.id = id;
    this.price = price;
    this.title = title;
    this.currencyCode = currencyCode;
    this.subscriptionPeriod = subscriptionPeriod;
  }

  Product.jsonForAndroid(SKDetails skDetails){
    this.skDetails = skDetails;
  }

  factory Product.fromJsonIOS(dynamic json) {
    if(kDebugMode) print(json);
    var subscriptionPeriod = new SubscriptionPeriod.fromMap(json['subscriptionPeriod'] as Map<String, dynamic>);
    return Product.jsonForIOS(json['productId'] as String, json['productPrice'] as double,
        json['productTitle'] as String, json['currencyCode'] as String, subscriptionPeriod);
  }

  factory Product.fromJsonAndroid(dynamic json) {
    if(kDebugMode) print(json);
    return Product.jsonForAndroid(new SKDetails.from(jsonDecode(json['skuDetails'])));
  }
  @override
  String toString() {
    if(skDetails == null)
      return 'Product(id: $id, price: $price, title: $title, currencyCode: $currencyCode, subscriptionPeriod: $subscriptionPeriod)';
    else
      return 'Product(skDetails: $skDetails)';
  }
}

class SubscriptionPeriod {
  String? unit;
  late int numberOfUnits;

  SubscriptionPeriod.fromMap(Map<String, dynamic> map) {
    unit = map['periodUnit'].toString();
    numberOfUnits = map['numberOfUnits'] as int;
  }
}

class SKDetails{
  late String productId;
  late String type;
  late String title;
  late String name;
  late String iconUrl;
  late String description;
  late String price;
  late int priceAmountMicros;
  late String priceCurrencyCode;
  late String skuDetailsToken;
  late String subscriptionPeriod;

  SKDetails.from(Map json) {
    productId = json['productId'].toString();
    type = json['type'].toString();
    title = json['title'].toString();
    name = json['name'] as String;
    iconUrl = json['iconUrl'].toString();
    description = json['description'] as String;
    price = json['price'] as String;
    priceAmountMicros = json['price_amount_micros'] as int;
    priceCurrencyCode = json['price_currency_code'].toString();
    skuDetailsToken = json['skuDetailsToken'] as String;
    subscriptionPeriod = json['subscriptionPeriod'] as String;
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
  @override
  String toString() {
    return 'PurchaseResult(subscriptionId: $subscriptionId, planId: $planId, status: $status)';
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
