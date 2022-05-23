// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sku_product_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkuProductDetailsWrapper _$SkuProductDetailsWrapperFromJson(
    Map<String, dynamic> json) {
  return SkuProductDetailsWrapper(
    json['productId'] as String,
    json['type'] as String,
    json['title'] as String,
    json['name'] as String,
    json['description'] as String,
    json['price'] as String,
    json['price_amount_micros'] as int,
    json['price_currency_code'] as String,
    json['subscriptionPeriod'] as String,
    json['skuDetailsToken'] as String,
  );
}

Map<String, dynamic> _$SkuProductDetailsWrapperToJson(
        SkuProductDetailsWrapper instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'type': instance.type,
      'title': instance.title,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'price_amount_micros': instance.priceAmountMicros,
      'price_currency_code': instance.priceCurrencyCode,
      'subscriptionPeriod': instance.subscriptionPeriod,
      'skuDetailsToken': instance.skuDetailsToken,
    };
