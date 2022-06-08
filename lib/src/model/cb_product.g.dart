// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cb_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CBProduct _$CBProductFromJson(Map<String, dynamic> json) {
  return CBProduct(json['productId'] as String?,
      json['productPrice'] as String?, json['productTitle'] as String?
      // CBMapper.skuPropertiesFromJson(json['skuDetails']),
      // json['skuDetails'] as Map<String, dynamic>
      );
}

Map<String, dynamic> _$CBProductToJson(CBProduct instance) => <String, dynamic>{
      'productId': instance.productId,
      'productPrice': instance.productPrice,
      'productTitle': instance.productTitle
      //'skuDetails': instance.skuDetails,
    };
