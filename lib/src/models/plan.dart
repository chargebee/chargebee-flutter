import 'dart:core';
/// This class contains all the information related to the Plans which associated with a subscription
class CBPlan {
  /// The plan identifier as same as product id.
  String? id;
  /// The plan name as same as product id.
  String? name;
  String? invoiceName;
  /// The cost of the plan price when the pricing model is flat_fee.
  int? price;
  /// If subscriptions or invoices exist for this plan price, period cannot be changed.
  int? period;
  /// The unit of time for period. eg. day, week, month and year.
  String? periodUnit;
  //// If subscriptions, invoices or differential prices exist for this plan price, pricing_model cannot be changed.
  String? pricingModel;
  /// the subscriptions of this plan price will have.
  int? freeQuantity;
  int? setup_cost;
  /// Plan status, eg. active, archived and delete.
  String? status;
  /// Allow the plan to subscribed to via Checkout.
  bool? enabledInHostedPages;
  /// Allow customers to change their subscription to this plan via the Self-Serve Portal.
  bool? enabledInPortal;
  String? addonApplicability;
  /// Indicates that the plan is a physical product.
  bool? isShippable;
  /// Timestamp indicating when the plan was last updated.
  int? updatedAt;
  /// Specifies if gift subscriptions can be created for this plan.
  bool? giftable;
  /// Plan channel as app_store/play_store/web
  String? channel;
  /// The version of the resource.
  int? resourceVersion;
  /// the plan object model
  String? object;
  String? chargeModel;
  /// Specifies whether taxes apply to this plan price.
  bool? taxable;
  /// The currency code of the plan
  String? currencyCode;
  bool? showDescriptionInInvoices;
  bool? showDescriptionInQuotes;
  /// A set of key-value pairs stored as additional information for the subscription and it can be optional
  String? metaData;

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
        this.metaData,
        });

  /// Mapping json data into CBPlan for iOS
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

  /// Mapping json data into CBPlan for Android
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

/// This class holds the list of chargebee plans
class CBPlansList {
  CBPlan? cbPlan;

  CBPlansList({this.cbPlan});

  /// Convert plan object into CBPlan for iOS
  CBPlansList.fromJson(Map<String, dynamic> json) {
    cbPlan = json['plan'] != null
        ? CBPlan.fromJson(json['plan'])
        : null;
  }

  /// Convert plan object into CBPlan for Android
  CBPlansList.fromJsonAndroid(Map<String, dynamic> json) {
    cbPlan = json['plan'] != null
        ? CBPlan.fromJsonAndroid(json['plan'])
        : null;
  }
}

class CBPlanWrapper {
  List<CBPlan>? list;

  CBPlanWrapper({this.list});

  CBPlanWrapper.fromJson(List<Map<String, dynamic>> json) {
    final subsArray = <CBPlan>[];
    for (final value in json) {
      subsArray.add(CBPlan.fromJson(value));
    }
  }
}
