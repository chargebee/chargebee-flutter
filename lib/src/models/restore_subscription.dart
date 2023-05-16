import 'package:flutter/cupertino.dart';

class CBRestoreSubscription{
  /// subscriptionId
  late String subscriptionId;
  /// planId
  late String planId;
  /// subscription status on store
  late String storeStatus;

  CBRestoreSubscription(this.subscriptionId, this.planId, this.storeStatus);

  /// convert json data into CBRestoreSubscription model
  factory CBRestoreSubscription.fromJson(Map<String, dynamic> json) {
    debugPrint('json: $json');
    return CBRestoreSubscription(json['subscriptionId'] as String, json['planId'] as String, json['storeStatus'] as String);
  }

  @override
  String toString() => 'CBRestoreSubscription(subscriptionId: $subscriptionId, planId: $planId, storeStatus: $storeStatus)';
}

enum StoreStatus {
  active,
  in_trial,
  cancelled,
  paused
}