/// This class contains all the information related to the Items which associated with a subscription
class CBItem {
  /// The item identifier as same as product id.
  String? id;
  /// The name is same as product id.
  String? name;
  /// Description of the item.
  String? description;
  /// Item status, eg. active, archived and delete.
  String? status;
  /// The version of the resource.
  int? resourceVersion;
  /// Timestamp indicating when the item was last updated.
  int? updatedAt;
  /// The id of the Item family that the item belongs.
  String? itemFamilyId;
  /// The type of the item, eg. plan, addon and charge.
  String? type;
  /// Indicates that the item is a physical product.
  bool? isShippable;
  /// Specifies if gift subscriptions can be created for this item.
  bool? isGiftable;
  /// Allow the plan/item to subscribed to via Checkout.
  bool? enabledForCheckout;
  /// Allow customers to change their subscription to this plan via the Self-Serve Portal.
  bool? enabledInPortal;
  /// Specifies whether the item undergoes metered billing.
  bool? metered;
  /// the item object model
  String? object;

  CBItem(
      {this.id,
      this.name,
      this.description,
      this.status,
      this.resourceVersion,
      this.updatedAt,
      this.itemFamilyId,
      this.type,
      this.isShippable,
      this.isGiftable,
      this.enabledForCheckout,
      this.enabledInPortal,
      this.metered,
      this.object,});

  /// Mapping json data into CBItem for iOS
  CBItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    resourceVersion = json['resource_version'];
    enabledInPortal = json['enabled_in_portal'] as bool;
    itemFamilyId = json['item_family_id'] as String;
    isShippable = json['is_shippable'] as bool;
    type = json['type'];
    object = json['object'] as String;
    metered = json['metered'] as bool;
    updatedAt = json['updated_at'] as int;
    enabledForCheckout = json['enabled_for_checkout'];
    isGiftable = json['is_giftable'] as bool;
    status = json['status'] as String;
    name = json['name'] as String;
  }
  /// Mapping json data into CBItem for Android
  CBItem.fromJsonAndroid(Map<String, dynamic> json) {
    id = json['channel'] as String;
    name = json['id'] as String;
    description = json['name'] as String;
    status = json['status'] as String;
  }
}

/// This class holds the list of chargebee items
class CBItemsList {
  CBItem? cbItem;

  CBItemsList({this.cbItem});

  /// Convert item object into CBItem for iOS
  CBItemsList.fromJson(Map<String, dynamic> json) {
    cbItem = json['item'] != null ? CBItem.fromJson(json['item']) : null;
  }

  /// Convert item object into CBItem for Android
  CBItemsList.fromJsonAndroid(Map<String, dynamic> json) {
    cbItem =
        json['item'] != null ? CBItem.fromJsonAndroid(json['item']) : null;
  }
}

class CBItemWrapper {
  List<CBItem>? list;

  CBItemWrapper({this.list});

  CBItemWrapper.fromJson(List<Map<String, dynamic>> json) {
    final subsArray = <CBItem>[];
    for (final value in json) {
      subsArray.add(CBItem.fromJson(value));
    }
  }
}
