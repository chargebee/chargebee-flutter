class Constants {
  /// Platform channel name
  static const methodChannelName = 'chargebee_flutter';

  /// Key params passed to plugin
  static const siteName = 'site_name';
  static const apiKey = 'api_key';
  static const sdkKey = 'sdk_key';
  static const packageName = 'package_name';
  static const productIDs = 'product_id';
  static const product = 'product';
  static const params = 'params';
  static const includeInactivePurchases = 'includeInactivePurchases';
  static const productType = 'product_type';
  static const productId = 'productId';
  static const applicationId = 'applicationId';
  static const offerToken = 'offerToken';

  /// API name for both iOS and Android
  static const mAuthentication = 'authentication';
  static const mRetrieveAllItems = 'retrieveAllItems';
  static const mRetrieveAllPlans = 'retrieveAllPlans';
  static const mGetProducts = 'getProducts';
  static const mPurchaseProduct = 'purchaseProduct';
  static const mSubscriptionMethod = 'retrieveSubscriptions';
  static const mProductIdentifiers = 'retrieveProductIdentifiers';
  static const mGetEntitlements = 'retrieveEntitlements';
  static const mRestorePurchase = 'restorePurchases';
  static const mValidateReceipt = 'validateReceipt';
  static const mPurchaseNonSubscriptionProduct =
      'purchaseNonSubscriptionProduct';
  static const mValidateReceiptForNonSubscriptions =
      'validateReceiptForNonSubscriptions';
  static const mShowManageSubscriptionsSettings = 'showManageSubscriptionsSettings';

  /// Customer info
  static const customerId = 'customerId';
  static const firstName = 'firstName';
  static const lastName = 'lastName';
  static const email = 'email';
}
