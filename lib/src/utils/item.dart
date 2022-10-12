
class CBItem{
  String? id;
  String? name;
  String? description;
  String? status;
  String? resourceVersion;
  String? updatedAt;
  String? itemFamilyId;
  String? type;
  String? isShippable;
  String? isGiftable;
  String? enabledForCheckout;
  String? enabledInPortal;
  String? metered;
  String? object;

  CBItem(
  {this.id,
  this.name,
  this.description,
  this.status,
  this.resourceVersion,
  this.updatedAt,
  this.itemFamilyId,this.type,
    this.isShippable,
    this.isGiftable,
    this.enabledForCheckout,
    this.enabledInPortal,
    this.metered,
    this.object});

  CBItem.fromJson(Map<String, dynamic> json) {
  id = json['id'] as String;
  name = json['name'] as String;
  description = json['description'] as String;
  status = json['status'] as String;
  resourceVersion = json['resourceVersion'] as String;
  updatedAt = json['updatedAt'] as String;
  itemFamilyId = json['itemFamilyId'] as String;
  type = json['type'] as String;
  isShippable = json['isShippable'] as String;
  isGiftable = json['isGiftable'] as String;
  enabledForCheckout = json['enabledForCheckout'] as String;
  enabledInPortal = json['enabledInPortal'] as String;
  metered = json['metered'] as String;
  object = json['object'] as String;

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

  CBItemsList.fromJson(Map<String, dynamic> json) {
     new CBItem.fromJson(json);
  }

  CBItemsList.fromJsonAndroid(dynamic json) {
    cbItem = json['item'] != null
        ? new CBItem.fromJsonAndroid(json['item'])
        : null;
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


