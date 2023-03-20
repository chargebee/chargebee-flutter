import 'dart:core';

class CBPlan {
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
  bool? enabledInHostedPages;
  bool? enabledInPortal;
  String? addonApplicability;
  bool? isShippable;
  int? updatedAt;
  bool? giftable;
  String? channel;
  int? resourceVersion;
  String? object;
  String? chargeModel;
  bool? taxable;
  String? currencyCode;
  bool? showDescriptionInInvoices;
  bool? showDescriptionInQuotes;
  String? metaData;

  CBPlan({
    this.id,
    this.name,
    this.invoiceName,
    this.price,
    this.period,
    this.periodUnit,
    this.pricingModel,
    this.freeQuantity,
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
    this.metaData,
  });

  CBPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    chargeModel = json['charge_model'] as String;
    resourceVersion = json['resource_version'] as int;
    enabledInPortal = json['enabled_in_portal'] as bool;
    freeQuantity = json['free_quantity'] as int;
    period = json['period'] as int;
    taxable = json['taxable'] as bool;
    pricingModel = json['pricing_model'] as String;
    isShippable = json['is_shippable'] as bool;
    currencyCode = json['currency_code'] as String;
    addonApplicability = json['addon_applicability'] as String;
    periodUnit = json['period_unit'] as String;
    giftable = json['giftable'] as bool;
    enabledInHostedPages = json['enabled_in_hosted_pages'] as bool;
    object = json['object'] as String;
    price = json['price'] as int;
    updatedAt = json['updated_at'] as int;
    status = json['status'] as String;
    name = json['name'] as String;
  }

  CBPlan.fromJsonAndroid(Map<String, dynamic> json) {
    addonApplicability = json['addonApplicability'] as String;
    channel = json['channel'] as String;
    chargeModel = json['chargeModel'] as String;
    currencyCode = json['currencyCode'] as String;
    enabledInHostedPages = json['enabledInHostedPages'] as bool;
    enabledInPortal = json['enabledInPortal'] as bool;
    freeQuantity = json['freeQuantity'] as int;
    giftable = json['giftable'] as bool;
    id = json['id'] as String;
    invoiceName = json['invoiceName'] as String;
    isShippable = json['isShippable'] as bool;
    name = json['name'] as String;
    object = json['object'] as String;
    period = json['period'] as int;
    periodUnit = json['periodUnit'] as String;
    price = json['price'] as int;
    pricingModel = json['pricingModel'] as String;
    resourceVersion = json['resourceVersion'] as int;
    setup_cost = json['setup_cost'] as int;
    showDescriptionInInvoices = json['showDescriptionInInvoices'] as bool;
    showDescriptionInQuotes = json['showDescriptionInQuotes'] as bool;
    status = json['status'] as String;
    taxable = json['taxable'] as bool;
    updatedAt = json['updatedAt'] as int;
    metaData = json['metaData'] != null ? json['metaData'].toString() : null;
  }
}

class CBPlansList {
  CBPlan? cbPlan;

  CBPlansList({this.cbPlan});

  CBPlansList.fromJson(dynamic json) {
    cbPlan = json['plan'] != null ? new CBPlan.fromJson(json['plan']) : null;
  }

  CBPlansList.fromJsonAndroid(dynamic json) {
    cbPlan =
        json['plan'] != null ? new CBPlan.fromJsonAndroid(json['plan']) : null;
  }
}

class CBPlanWrapper {
  List<CBPlan>? list;

  CBPlanWrapper({this.list});

  CBPlanWrapper.fromJson(List<dynamic> json) {
    List<CBPlan> subsArray = [];
    for (var value in json) {
      subsArray.add(CBPlan.fromJson(value));
    }
  }
}
