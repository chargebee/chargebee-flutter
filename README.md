# Flutter SDK
Chargebee’s SDK for Flutter enables you to build a seamless and efficient customer experience for your subscription business.

Post-installation, initialization, and authentication with the Chargebee site, this SDK will support the following process.

1. **Sync In-App Subscriptions with Chargebee:** Integrate your App developed on Flutter with Chargebee to process and track in-app subscriptions of the [Apple App Store](https://appstoreconnect.apple.com/login) and [Google Play Store](https://play.google.com/console/about/) on your Chargebee account. Thus you can create a single source of truth for subscriptions across Apple, Google, and Web stores. Use this if you are selling digital goods or services or are REQUIRED to use Apple's and Google’s in-app purchases as per their app review guidelines([Apple](https://developer.apple.com/app-store/review/guidelines/) and [Google](https://developer.apple.com/app-store/review/guidelines/)). **For SDK methods to work, ensure that prerequisites([Apple](https://www.chargebee.com/docs/2.0/mobile-app-store-product-iap.html#configure-prerequisites) and [Google](https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html#prerequisites-configuration)) are configured in Chargebee**.

## Requirements
The following requirements must be set up before installing Chargebee’s Flutter SDK.

* Flutter version 2.10.0 and above
* Dart SDK version 2.16.2 and above
* [Android Gradle Plugin](https://developer.android.com/studio/releases/gradle-plugin) 4.0.0
* [Gradle](https://gradle.org/releases/) 6.1.1+
* [AndroidX](https://developer.android.com/jetpack/androidx/)
* Java 8+ and Kotlin
* iOS 12+
* Swift 5+

### Installation
To use Chargebee SDK in your Flutter app, follow these steps:

1. Add Chargebee as a dependency in your [pubspec.yaml](https://docs.flutter.dev/development/packages-and-plugins/using-packages) file

```dart
dependencies:
  chargebee_flutter: ^0.0.2
```
2. Install dependency
```dart
  flutter pub get
```

##Configuring SDK

##Prerequisites

Before configuring the Chargebee Flutter SDK for completing and managing In-App Purchases, follow these steps.

  1. **iOS:** [Integrate](https://www.chargebee.com/docs/2.0/mobile-app-store-connect.html) the [Apple Store Connect](https://appstoreconnect.apple.com/login) with your [Chargebee site](https://app.chargebee.com/login).
     **Android:** [Integrate](https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html#chargebee-configuration) Google Play Store with your [Chargebee site](https://app.chargebee.com/login).

  2. **iOS:** On the **Sync Overview** page of the web app, click **View Keys** and use the value of generated [App ID](https://www.chargebee.com/docs/1.0/mobile-app-store-product-iap.html#app-id) as the **SDK Key**.
     **Android:** On the **Sync Overview** page of the web app, click **Set up notifications** and use the generated [App ID](https://www.chargebee.com/docs/1.0/mobile-playstore-notifications.html#app-id) value as **SDK Key**.

  3. On the Chargebee site, navigate to **Configure Chargebee >** [API Keys](https://www.chargebee.com/docs/2.0/api_keys.html#create-an-api-key) to create a new **Publishable API Key** or use an existing [Publishable API Key](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key).
     **Note:** During the publishable API key creation you must allow **read-only** access to plans/items otherwise this key will not work in the following snippet. Read [more](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key).

Initialize the Chargebee Flutter SDK with your Chargebee site, Publishable API Key, and SDK Key by including the following snippets in your app delegate during app startup.

```dart
import 'package:chargebee_flutter/chargebee_flutter.dart';

try {
    await Chargebee.configure("SITE_NAME", "API-KEY", "iOS SDK Key", "Android SDK Key");
} on PlatformException catch (error) {
    log('PlatformException : ${error.message}');
}

```
### Integrating In-App Purchases
The section describes how to use the SDK to integrate In-App Purchase information. For details on In-App Purchase, Read [more](https://www.chargebee.com/docs/2.0/mobile-in-app-purchases.html).

### Get IAP Products
Retrieve the IAP Product objects with Product IDs using the following function.

```dart
try {
    List<Product> products = await Chargebee.retrieveProducts({productList: "[Product ID's from Google or Apple]"});
} catch (error) {
    print(error);
}
            
```
You can present any of the above products to your users for them to purchase.

### Buy or Subscribe Product
Pass the product and customer identifiers to the following function when the user chooses the product to purchase.

customerId - Optional parameter. We need the unique ID of your customer as customerId. If your unique list of customers is maintained in your database or a third-party system, send us the unique ID from that source.

```dart
try {
  final result = await Chargebee.purchaseProduct(product, customerId);
  print("subscription id : ${result.subscriptionId}");
  print("subscription status : ${result.status}");
}  catch (error) {
  print('Exception : $error');
}
 ```
The above function will handle the purchase against Google Play Store and send the IAP token for server-side token verification to your Chargebee account. Use the Subscription ID returned by the above function, to check for Subscription status on Chargebee and confirm the access - granted or denied.

### Get Subscription Status for Existing Subscribers using Query Parameters
Use this method to check the subscription status of a subscriber who has already purchased the product.

Use query parameters - Subscription ID, Customer ID, or Status for checking the Subscription status on Chargebee and confirm the access - granted or denied.

```dart
try {
  final result = await Chargebee.retrieveSubscriptions(queryParams);
}  catch (error) {
  print('Exception : $error');
}  
```
For example, query parameters can be passed as **"customer_id" : "id"**.

## License

Chargebee is available under the [MIT license](https://opensource.org/licenses/MIT). See the LICENSE file for more info.

