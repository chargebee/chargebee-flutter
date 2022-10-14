
class CBItem{
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
  this.itemFamilyId,this.type,
    this.isShippable,
    this.isGiftable,
    this.enabledForCheckout,
    this.enabledInPortal,
    this.metered,
    this.object});

  CBItem.fromJson(Map<String, dynamic> json) {
    id = json['channel'] as String;
    name = json['id'] as String;
    description = json['name'] as String;
    status = json['status'] as String;

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
    cbItem = json['item'] != null
        ? new CBItem.fromJson(json['item'])
        : null;
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


