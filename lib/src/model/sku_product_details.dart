
import 'dart:ui' show hashValues;

import 'package:chargebee_flutter_sdk/src/model/sku_product_details.dart';
import 'package:chargebee_flutter_sdk/src/model/sku_product_details.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sku_product_details.g.dart';
enum SkuType {
@JsonValue('inapp')
inapp,

@JsonValue('subs')
subs,
}

// Contains the details of an available product in Google Play Billing.
@JsonSerializable()
class SkuProductDetailsWrapper {
  @JsonKey(name: 'productId')
  final String productId;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'name')
  final String name;


  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'price')
  final String price;

  @JsonKey(name: 'price_amount_micros')
  final int priceAmountMicros;

  @JsonKey(name: 'price_currency_code')
  final String priceCurrencyCode;

  @JsonKey(name: 'subscriptionPeriod')
  final String subscriptionPeriod;

  @JsonKey(name: 'skuDetailsToken')
  final String skuDetailsToken;


  /// Creates a [SkuDetailsWrapper] with the given purchase details.
  SkuProductDetailsWrapper(
       this.productId,
         this.type,
         this.title,
         this.name,
         this.description,
         this.price,
         this.priceAmountMicros,
         this.priceCurrencyCode,
         this.subscriptionPeriod,
         this.skuDetailsToken
      );


  factory SkuProductDetailsWrapper.fromJson(dynamic json) {

   // {"productId":"merchant.pro.android","type":"subs","title":"Pro Plan (Chargebee Example)","name":"Pro Plan","description":"Annual Plan","price":"₹4,450.00","price_amount_micros":4450000000,"price_currency_code":"INR","subscriptionPeriod":"P1Y","skuDetailsToken":"AEuhp4IhBO_Cknb3WY2L_AvKQmeM_zt-qBfHTYUuFOA_vQyZY-Xd8dVM7OjTNOpbTXw="}
    return SkuProductDetailsWrapper( json['productId'] as String, json['type'] as String, json['title'] as String, json['name'] as String, json['description'] as String,
        json['price'] as String, json['price_amount_micros'] as int, json['price_currency_code'] as String,
        json['subscriptionPeriod'] as String,
        json['skuDetailsToken'] as String);
  }


  Map<String, dynamic> toJson() => _$SkuProductDetailsWrapperToJson(this);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SkuProductDetailsWrapper typedOther = other;
    return typedOther is SkuProductDetailsWrapper &&
        typedOther.productId == productId &&
        typedOther.description == description &&
        typedOther.name == name &&
        typedOther.price == price &&
        typedOther.priceAmountMicros == priceAmountMicros &&
        typedOther.priceCurrencyCode ==priceCurrencyCode &&
        typedOther.subscriptionPeriod == subscriptionPeriod &&
        typedOther.title == title &&
        typedOther.type == type &&
        typedOther.skuDetailsToken == skuDetailsToken;
  }

  @override
  int get hashCode {
    return hashValues(
        productId.hashCode,
        description.hashCode,
        name.hashCode,
        price.hashCode,
        priceAmountMicros.hashCode,
        priceCurrencyCode.hashCode,
        subscriptionPeriod.hashCode,
        title.hashCode,
        type.hashCode,
        skuDetailsToken.hashCode);
  }
}