import 'package:flutter/foundation.dart';

/// The class contains the information about Store Product
class Product {
  /// Id of the product
  late String id;
  /// title of the product
  late String title;
  /// Currency code for the price
  late String currencyCode;
  /// Local currency price for the product in double
  late double price;
  /// Local currency price for the product in string
  late String priceString;
  /// Subscription period, which consists of unit and number of units
  late SubscriptionPeriod subscriptionPeriod;

  Product(this.id, this.price, this.priceString, this.title, this.currencyCode, this.subscriptionPeriod);

  /// convert json data into Product model
  factory Product.fromJson(Map<String, dynamic> json) {
    debugPrint('json: $json');
    final subscriptionPeriod = SubscriptionPeriod.fromMap(json['subscriptionPeriod'] as Map<String, dynamic>);
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

  /// convert map object into SubscriptionPeriod
  SubscriptionPeriod.fromMap(Map<String, dynamic> map) {
    unit = map['periodUnit'].toString();
    numberOfUnits = map['numberOfUnits'] as int;
  }
}

/// Store the information related to product subscriptions
class PurchaseResult {
  /// product subscriptions id
  String subscriptionId;
  /// plan id associated with subscription
  String planId;
  //// status of the subscription
  String status;

  PurchaseResult(this.subscriptionId, this.planId, this.status);

  /// convert json data and returned PurchaseResult object
  factory PurchaseResult.fromJson(Map<String, dynamic> json) => PurchaseResult(json['subscriptionId'] as String,
        json['planId'] as String, json['status'] as String,);
  @override
  String toString() => 'PurchaseResult(subscriptionId: $subscriptionId, planId: $planId, status: $status)';
}

/// Store information about the list of subscriptions
class Subscripton {
  /// subscription id
  String? subscriptionId;
  /// customer id associated with subscription
  String? customerId;
  /// status of the subscription
  String? status;
  /// the subscription got activated time
  int? activatedAt;
  /// subscription term start
  int? currentTermStart;
  /// subscription term end
  int? currentTermEnd;
  String? planAmount;
  /// the subscription got activated time in string format
  String? activatedAtString;
  /// subscription term end
  String? currentTermEndString;
  /// subscription term start
  String? currentTermStartString;

  Subscripton(
      {this.subscriptionId,
      this.customerId,
      this.status,
      this.activatedAt,
      this.currentTermStart,
      this.currentTermEnd,
      this.planAmount,});

  /// convert json data into Subscripton model for iOS
  Subscripton.fromJson(Map<String, dynamic> json) {
    subscriptionId = json['subscription_id'] as String;
    customerId = json['customer_id'] as String;
    status = json['status'] as String;
    activatedAt = json['activated_at'] as int;
    currentTermStart = json['current_term_start'] as int;
    currentTermEnd = json['current_term_end'] as int;
    planAmount = json['plan_amount']
        .toString(); /// Plan amount sometime we are getting double value sometime Int
  }

  /// convert json data into Subscripton model for Android
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

/// Gets list of subscriptions
class SubscriptonList {
  /// subscription object
  Subscripton? subscripton;

  SubscriptonList({this.subscripton});

  /// json data converts into SubscriptonList for iOS
  SubscriptonList.fromJson(Map<String, dynamic> json) {
    subscripton = json['cb_subscription'] != null
        ? Subscripton.fromJson(json['cb_subscription'])
        : null;
  }
  /// json data converts into SubscriptonList for Android
  SubscriptonList.fromJsonAndroid(Map<String, dynamic> json) {
    subscripton = json['cb_subscription'] != null
        ? Subscripton.fromJsonAndroid(json['cb_subscription'])
        : null;
  }
}

class CBSubscriptionWrapper {
  List<Subscripton>? list;

  CBSubscriptionWrapper({this.list});

  CBSubscriptionWrapper.fromJson(List<Map<String, dynamic>> json) {
    final subsArray = <Subscripton>[];
    for (final value in json) {
      subsArray.add(Subscripton.fromJson(value));
    }
  }
}

class CBProductIdentifierWrapper {
  late List<String> productIdentifiersList;

  CBProductIdentifierWrapper(this.productIdentifiersList);

  factory CBProductIdentifierWrapper.fromJson(List<dynamic> json) {
    final productsList = <String>[];
    for (final value in json) {
      productsList.add(value);
    }
    return CBProductIdentifierWrapper(productsList);
  }
}

class CBEntitlementWrapper {
  late List<String> entitlementsList;

  CBEntitlementWrapper(this.entitlementsList);

  factory CBEntitlementWrapper.fromJson(List<dynamic> json) {
    final entitlementList = <String>[];
    for (final value in json) {
      entitlementList.add(value);
    }
    return CBEntitlementWrapper(entitlementList);
  }
}