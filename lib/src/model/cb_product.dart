import 'package:chargebee_flutter_sdk/src/utils/cb_support.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cb_product.g.dart';

@JsonSerializable()
class CBProduct {
  @JsonKey(name: 'productId')
  String? productId;
  @JsonKey(name: 'productPrice')
  String? productPrice;
  @JsonKey(name: 'productTitle')
  String? productTitle;

  // // // For Android only.
  // @JsonKey(name: 'skuDetails', fromJson: CBMapper.skuPropertiesFromJson)
  // SkuDetailsWrapper? skuDetails;

  // For Android only.
  // @JsonKey(name: 'skuDetails', fromJson: CBMapper.skuPropertiesFromJson)
  // Map<String, dynamic> skuDetails;

  CBProduct(this.productId, this.productPrice, this.productTitle) {
    productId = productId;
    productPrice = productPrice;
    productTitle = productTitle;
    // skuDetails = this.skuDetails;
    // skuDetails = this.skuDetails;
  }

  factory CBProduct.fromJson(dynamic json) {
    return CBProduct(
        json['productId'] as String,
        json['productPrice'] as String,
        json['productTitle']
            as String /*json["skuDetails"] as Map<String, dynamic>*/);
  }

  Map<String, dynamic> toJson() => _$CBProductToJson(this);
}
