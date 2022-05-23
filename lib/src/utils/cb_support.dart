
import 'dart:convert';

import 'package:chargebee_flutter_sdk/src/model/cb_product.dart';
import 'package:chargebee_flutter_sdk/src/model/sku_product_details.dart';

import '../model/sku_Item.dart';

class CBMapper {

  static Map<String, CBProduct> productsFromJson(dynamic json) {
    if (json == null) return <String, CBProduct>{};

    final productsMap = Map<String, dynamic>.from(json);

    return productsMap.map((key, value) {
      final productMap = Map<String, dynamic>.from(value);
      return MapEntry(key, CBProduct.fromJson(productMap));
    });
  }

  static CBProduct cbProductsFromJson(String json) {
    print('Json Data from Chargebee class : $json');

    CBProduct cbProduct = CBProduct.fromJson(jsonDecode(json));

    print('skus ------- : ${cbProduct.skuDetails}');

    return cbProduct;
  }

  static SkuProductDetailsWrapper? skuDetailsFromJson(dynamic json) {
    if (json == null) return null;

    final map = Map<String, dynamic>.from(json);

    try {
      return SkuProductDetailsWrapper.fromJson(map);
    } catch (e) {
      print('Could not parse SkuDetails from SkuProductDetailsWrapper: $e');
      return null;
    }
  }

  static Map<String, dynamic>? skuMapFromJson(dynamic json) {
   // if (json == null) return null;

    final map = Map<String, dynamic>.from(json);

    try {
      return map;
    } catch (e) {
      print('Could not parse SkuDetails from SkuProperties: $e');
      return null;
    }
  }


  static SkuDetailsWrapper? skuPropertiesFromJson(dynamic json) {
     if (json == null) return null;

    final map = Map<String, dynamic>.from(json);

    try {
      return SkuDetailsWrapper.fromJson(json);
    } catch (e) {
      print('Could not parse SkuDetails from SkuProperties: $e');
      return null;
    }
  }

  
}