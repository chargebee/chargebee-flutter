# Flutter SDK

Chargebee's Flutter SDK enables you to build a seamless and efficient customer experience for your subscription business.

Post-installation, initialization, and authentication with the Chargebee site, this SDK will support the following process.

-   **Sync In-App Subscriptions with Chargebee**: Integrate your App developed on Flutter with Chargebee to process and track in-app subscriptions of the [Apple App Store](https://appstoreconnect.apple.com/login "https://appstoreconnect.apple.com/login") and [Google Play Store](https://play.google.com/console/about/ "https://play.google.com/console/about/") on your Chargebee account. Thus you can create a single source of truth for subscriptions across Apple, Google, and Web stores. Use this if you are selling digital goods or services or are REQUIRED to use Apple's and Google's in-app purchases as per their app review guidelines ([Apple](https://developer.apple.com/app-store/review/guidelines/ "https://developer.apple.com/app-store/review/guidelines/") and [Google](https://support.google.com/googleplay/android-developer/answer/9858738 "https://support.google.com/googleplay/android-developer/answer/9858738")). **For SDK methods to work, ensure that prerequisites ([**Apple**](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#configure-prerequisites "https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#configure-prerequisites") and [**Google**](https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html#prerequisites-configuration "https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html#prerequisites-configuration")) are configured in Chargebee.**

## Requirements

The following requirements must be set up before installing Chargebee's Flutter SDK.

-   Flutter version 2.10.0 and above
-   Dart SDK version 2.16.2 and above
-   [Android Gradle Plugin](https://developer.android.com/studio/releases/gradle-plugin "https://developer.android.com/studio/releases/gradle-plugin") 4.0.0
-   [Gradle](https://gradle.org/releases/ "https://gradle.org/releases/") 6.1.1+
-   [AndroidX](https://developer.android.com/jetpack/androidx/ "https://developer.android.com/jetpack/androidx/")
-   Java 8+ and Kotlin
-   iOS 12+
-   Swift 5+

## Installation

To use Chargebee SDK in your Flutter app, follow these steps:

1.  Add Chargebee as a dependency in your [pubspec.yaml](https://flutter.io/platform-plugins/ "https://flutter.io/platform-plugins/")file.

    ``` dart
    dependencies: 
     chargebee_flutter: ^0.0.12
    ```
    
2.  Install dependency.

    ``` dart
    flutter pub get
    ```

## Configuring SDK

**Prerequisites**
Before configuring the Chargebee Flutter SDK for syncing In-App Purchases, follow these steps.

1.  **iOS**: [Integrate](https://www.chargebee.com/docs/2.0/mobile-app-store-connect.html "https://www.chargebee.com/docs/2.0/mobile-app-store-connect.html") the [Apple App Store account](https://appstoreconnect.apple.com/login "https://appstoreconnect.apple.com/login") with your [Chargebee site](https://app.chargebee.com/login "https://app.chargebee.com/login").   
 **Android**: [Integrate](https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html "https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html") [Google Play Store account](https://play.google.com/console/about/ "https://play.google.com/console/about/") with your [Chargebee site](https://app.chargebee.com/login "https://app.chargebee.com/login").
2.  **iOS**: On the**Sync Overview** pageof theweb app, click **View Keys** and use the value of generated [**App ID**](https://www.chargebee.com/docs/1.0/mobile-app-store-product-iap.html#app-id "https://www.chargebee.com/docs/1.0/mobile-app-store-product-iap.html#app-id") as the **SDK Key**.    
**Android**: On the **Sync Overview** page of the web app, click **Set up notifications** and use the generated [**App ID**](https://www.chargebee.com/docs/1.0/mobile-playstore-notifications.html#app-id "https://www.chargebee.com/docs/1.0/mobile-playstore-notifications.html#app-id") value as the **SDK Key**.
3.  On the Chargebee site, navigate to **Configure Chargebee** > [**API Keys**](https://www.chargebee.com/docs/2.0/api_keys.html#create-an-api-key "https://www.chargebee.com/docs/2.0/api_keys.html#create-an-api-key") to create a new **Publishable API Key** or use an existing [**Publishable API Key**](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key "https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key").

**Note:** During the publishable API key creation you must allow **read-only** access to plans/items otherwise this key will not work in the following snippet. Read [more](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key "https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key").

Initialize the Chargebee Flutter SDK with your Chargebee site, Publishable API Key, and SDK Keys by including the following snippets in your app delegate during app startup.

``` dart
import 'package:chargebee_flutter/chargebee_flutter.dart';
try {
  await Chargebee.configure("SITE_NAME", "API-KEY", "iOS SDK Key", "Android SDK Key");
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```

## Integrating In-App Purchases

This section describes how to use the SDK to integrate In-App Purchase information. For details on In-App Purchase, read [more](https://www.chargebee.com/docs/2.0/mobile_subscriptions.html "https://www.chargebee.com/docs/2.0/mobile_subscriptions.html").

#### Get all IAP Product Identifiers from Chargebee

Every In-App Purchase subscription product that you configure in your account, can be configured in Chargebee as a Plan. Start by retrieving the IAP Product IDs from your Chargebee account using the following function.

``` dart
try {
  final result = await Chargebee.retrieveProductIdentifiers(queryparam);
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```
For example, query parameters can be passed as **"limit": "100"**.

#### Get IAP Products

Retrieve the IAP Product objects with Product IDs using the following function.

``` dart
try {
  List<Product> products = await Chargebee.retrieveProducts({productList: "[Product ID's from Google or Apple]"});
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```
You can present any of the above products to your users for them to purchase.

#### Buy or Subscribe Product

Pass the product and customer identifier to the following function when your customer chooses the product to purchase.

`customerId` -  **Optional parameter**. Although this is an optional parameter, we recommend passing customerId if it is available before user subscribes on your App. Passing this parameter ensures that customerId in your database matches with the customerId in Chargebee.
In case this parameter is not passed, then the **customerId** will be the same as the **SubscriptionId** created in Chargebee.

``` dart
try {
  final result = await Chargebee.purchaseProduct(product, customerId);
  print("subscription id : ${result.subscriptionId}");
  print("subscription status : ${result.status}");
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```

The above function will handle the purchase against Apple App Store or Google Play Store and send the in-app purchase receipt for server-side receipt verification to your Chargebee account. Use the Subscription ID returned by the above function to check for Subscription status on Chargebee and confirm the access - granted or denied.

#### Restore Purchases

The `restorePurchases()` function helps to recover your app user's previous purchases without making them pay again. Sometimes, your app user may want to restore their previous purchases after switching to a new device or reinstalling your app. You can use the `restorePurchases()` function to allow your app user to easily restore their previous purchases.

To retrieve **inactive** purchases along with the **active** purchases for your app user, you can call the `restorePurchases()` function with the `includeInactivePurchases` parameter set to true. If you only want to restore active subscriptions, set the parameter to false. Here is an example of how to use the restorePurchases() function in your code with the `includeInactivePurchases` parameter set to true.

``` dart
try {
  final result = await Chargebee.restorePurchases(true);
  print("result : $result");
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```

##### Error Handling
In the event of any failures while finding associated subscriptions for the restored items, The SDK will return an error, as mentioned in the following table.

These are the possible error codes and their descriptions:
| Error Code                        | Description                                                                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| 2014            | This error occurs when the user attempts to restore a purchase, but there is no receipt associated with the purchase.       |
| 2015 | This error occurs when the attempt to refresh the receipt for a purchase fails.                                             |
| 2016        | This error occurs when the attempt to restore a purchase fails for reasons other than a missing or invalid receipt.         |
| 2017  | This error occurs when the URL for the receipt bundle provided during the restore process is invalid or cannot be accessed.                                                         |
| 2018         | This error occurs when the data contained within the receipt is not valid or cannot be parsed.                          |
| 2019         | This error occurs when there are no products available to restore.                             |
| 2020         | This error occurs when there is an error with the Chargebee service during the restore process.

#### Synchronization of Apple App Store/Google Play Store Purchases with Chargebee through Receipt Validation
Receipt validation is crucial to ensure that the purchases made by your users are synced with Chargebee. In rare cases, when a purchase is made at the Apple App Store/Google Play Store, and the network connection goes off or the server not responding, the purchase details may not be updated in Chargebee. In such cases, you can use a retry mechanism by following these steps:

* Add a network listener, as shown in the example project.
* Save the product identifier in the cache once the purchase is initiated and clear the cache once the purchase is successful.
* When the network connectivity is lost after the purchase is completed at Apple App Store/Google Play Store but not synced with Chargebee, retrieve the product from the cache once the network connection is back and initiate validateReceipt() by passing `productId` and `CBCustomer(optional)` as input. This will validate the receipt and sync the purchase in Chargebee as a subscription. For subscriptions, use the function to validateReceipt().

Use the function available for the retry mechanism.
##### Function for validating the receipt

``` dart
try {
  final result = await Chargebee.validateReceipt(productId);
  print("subscription id : ${result.subscriptionId}");
  print("subscription status : ${result.status}");
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```

#### Get Subscription Status for Existing Subscribers using Query Parameters

Use this method to check the subscription status of a subscriber who has already purchased the product.

Use query parameters - Subscription ID, Customer ID, or Status for checking the Subscription status on Chargebee and confirm the access - granted or denied.

``` dart
try {
  final result = await Chargebee.retrieveSubscriptions(queryparam);
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```

For example, query parameters can be passed as **"customer_id" : "id"**, **"subscription_id": "id"**, or **"status": "active"**.

#### Retrieve Entitlements of a Subscription

Use the query parameter - Subscription ID for retrieving the list of [entitlements](https://www.chargebee.com/docs/2.0/entitlements.html) associated with the subscription.

``` dart
try {
  final result = await Chargebee.retrieveEntitlements(queryparam);
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```
For example, query parameters can be passed as **"subscriptionId": "id"**.

**Note**: Entitlements feature is available only if your Chargebee site is on [Product Catalog 2.0](https://www.chargebee.com/docs/2.0/product-catalog.html).

#### Get all items

If your Chargebee site is configured to Product Catalog 2.0, use the following functions to retrieve the item list.

``` dart
try {
  final result = await Chargebee.retrieveAllItems(queryparam);
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```
For example, query parameters can be passed as **"sort_by[desc]" : "name"** or **"limit": "100"**.

#### Get All Plans

If your Chargebee site is configured to Product Catalog 1.0, use the relevant functions to retrieve the plan list.

``` dart
try {
  final result = await Chargebee.retrieveAllPlans(queryparam);
} on PlatformException catch (e) {
  print('Error Message: ${e.message}, Error Details: ${e.details}, Error Code: ${e.code}');
}
```
For example, query parameters can be passed as **"sort_by[desc]" : "name"** or **"limit": "100"**.

## License

Chargebee is available under the [MIT license](https://opensource.org/licenses/MIT "https://opensource.org/licenses/MIT"). For more information, see the LICENSE file.
