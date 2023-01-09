class CBItem {
  String? id;
  String? name;
  String? description;
  String? status;
  int? resourceVersion;
  int? updatedAt;
  String? itemFamilyId;
  String? type;
  bool? isShippable;
  bool? isGiftable;
  bool? enabledForCheckout;
  bool? enabledInPortal;
  bool? metered;
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
      this.object});

  CBItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    resourceVersion = json['resource_version'];
    enabledInPortal = json['enabled_in_portal'] as bool;
    status = json['item_family_id'] as String;
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

  CBItem.fromJsonAndroid(Map<String, dynamic> json) {
    id = json['channel'] as String;
    name = json['id'] as String;
    description = json['name'] as String;
    status = json['status'] as String;
  }
}

class CBItemsList {
  CBItem? cbItem;

  CBItemsList({this.cbItem});

  CBItemsList.fromJson(dynamic json) {
    cbItem = json['item'] != null ? new CBItem.fromJson(json['item']) : null;
  }

  CBItemsList.fromJsonAndroid(dynamic json) {
    cbItem =
        json['item'] != null ? new CBItem.fromJsonAndroid(json['item']) : null;
  }
}

class CBItemWrapper {
  List<CBItem>? list;

  CBItemWrapper({this.list});

  CBItemWrapper.fromJson(List<dynamic> json) {
    print(json);
    List<CBItem> subsArray = [];
    for (var value in json) {
      print(value);
      subsArray.add(CBItem.fromJson(value));
    }
  }
}
