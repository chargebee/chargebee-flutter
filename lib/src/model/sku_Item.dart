
import 'package:chargebee_flutter_sdk/src/model/sku_product_details.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/cb_support.dart';

part 'sku_Item.g.dart';


@JsonSerializable()
class SkuDetailsWrapper {

  @JsonKey(name: 'zza', fromJson: CBMapper.skuDetailsFromJson)
  String skuDetails;

  SkuDetailsWrapper(this.skuDetails) {
    skuDetails = this.skuDetails;
  }

  factory SkuDetailsWrapper.fromJson(dynamic json) {
    return SkuDetailsWrapper(json['zza'] as String);
  }

  Map<String, dynamic> toJson() => _$SkuDetailsWrapperToJson(this);
}