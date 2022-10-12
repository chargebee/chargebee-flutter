
import 'dart:ffi';

class CBPlan{
  String? id;
  String? name;
  String? invoiceName;
  int? price;
  int? period;
  String? periodUnit;
  String? pricingModel;
  int? freeQuantity;
  int? setup_cost;
  String? status;
  Bool? enabledInHostedPages;
  Bool? enabledInPortal;
  String? addonApplicability;
  Bool? isShippable;
  int? updatedAt;
  Bool? giftable;
  String? channel;
  int? resourceVersion;
  String? `object;
  String? chargeModel;
  Bool? taxable;
  String? currencyCode;
  Bool? showDescriptionInInvoices;
  Bool? showDescriptionInQuotes;
  //String? metaData;

  CBPlan(
      {this.id,
        this.name,
        this.invoiceName,
        this.price,
        this.period,
        this.periodUnit,
        this.pricingModel,this.freeQuantity,
        this.setup_cost,
        this.status,
        this.enabledInHostedPages,
        this.enabledInPortal,
        this.addonApplicability,
        this.isShippable,
        this.updatedAt,
        this.giftable,
        this.channel,
        this.resourceVersion,
        this.object,
        this.chargeModel,
        this.taxable,
        this.currencyCode,
        this.showDescriptionInInvoices,
        this.showDescriptionInQuotes,
        });

  CBPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    name = json['name'] as String;


  }

  CBPlan.fromJsonAndroid(Map<String, dynamic> json) {
    id = json['channel'] as String;
    name = json['id'] as String;
    invoiceName = json['name'] as String;
    price = json['status'] as int;
    period = json['channel'] as int;
    periodUnit = json['id'] as String;
    pricingModel = json['name'] as int;
    freeQuantity = json['status'] as int;
    setup_cost = json['channel'] as int;
    status = json['id'] as String;
    enabledInHostedPages = json['name'] as Bool;
    enabledInPortal = json['status'] as Bool;
    addonApplicability = json['channel'] as String;
    isShippable = json['id'] as Bool;
    updatedAt = json['name'] as int;
    giftable = json['status'] as Bool;
    channel = json['id'] as String;
    resourceVersion = json['name'] as int;
    object = json['status'] as String;
    chargeModel = json['channel'] as String;
    taxable = json['id'] as Bool;
    currencyCode = json['name'] as String;
    showDescriptionInInvoices = json['status'] as Bool;
    showDescriptionInQuotes = json['status'] as Bool;
  }

}

class CBPlansList {
  CBPlan? cbItem;

  CBPlansList({this.cbItem});

  CBPlansList.fromJson(dynamic json) {
    cbItem = json['plan'] != null
        ? new CBPlan.fromJsonAndroid(json['item'])
        : null;
  }

  CBPlansList.fromJsonAndroid(dynamic json) {
    cbItem = json['plan'] != null
        ? new CBPlan.fromJsonAndroid(json['item'])
        : null;
  }

}

class CBPlanWrapper {
  List<CBPlan>? list;

  CBPlanWrapper({this.list});

  CBPlanWrapper.fromJson(List<dynamic> json) {
    print(json);
    List<CBPlan> subsArray = [];
    for (var value in json) {
      print(value);
      subsArray.add(CBPlan.fromJson(value));
    }

  }
}


