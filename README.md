# Chargebee Flutter
This is Chargebee’s Flutter Software Development Kit (SDK). This SDK makes it efficient and comfortable to build a seamless subscription experience in your Flutter app.

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

## Installation
The `Chargebee-Flutter-SDK` SDK can be installed by adding below dependency to the `pubspec.yaml` file:

```dart
dependencies:
  chargebee_flutter_sdk: ^1.0.0
```

## Example project
This is an optional step that helps you verify the SDK implementation using this example project. You can download or clone the example project via GitHub.

To run the example project, follow these steps.

1. Clone the repo - https://github.com/chargebee/chargebee-android.

2. Run build.gradle from the Example directory.

## Configuration

* Configuration for In-App Purchases

### Configuration for In-App Purchases
To configure the Chargebee Flutter SDK for completing and managing In-App Purchases, follow these steps.

1. [Integrate](https://www.chargebee.com/docs/2.0/mobile-playstore-connect.html) Google Play Store with your [Chargebee site](https://app.chargebee.com/sites/select).

2. On the **Sync Overview** page of the web app, click **Set up notifications** and use the generated [App ID](https://www.chargebee.com/docs/1.0/mobile-playstore-notifications.html#app-id) value as **SDK Key**.

3. On the Chargebee site, navigate to **Settings** > **Configure Chargebee** > [API Keys](https://www.chargebee.com/docs/2.0/api_keys.html#create-an-api-key) to create a new [Publishable API Key](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key) or use an existing Publishable API Key.
   **Note:** During the publishable API key creation you must allow **read-only** access to plans/items otherwise this key will not work in the following step. Read [more](https://www.chargebee.com/docs/2.0/api_keys.html#types-of-api-keys_publishable-key).

4. Initialize the SDK with your Chargebee site, **Publishable API Key**, and SDK Key by including the following snippets in your app delegate during app startup.

```dart
import 'package:chargebee_flutter_sdk/chargebee_flutter_sdk.dart';

Chargebee.configure(site: "your-site", apiKey: "publishable_api_key", sdkKey: "ResourceID/SDK Key")

```
### Integrating In-App Purchases
The following section describes how to use the SDK to integrate In-App Purchase information. For details on In-App Purchase, read more [here](https://www.chargebee.com/docs/2.0/mobile-in-app-purchases.html).

### Get IAP Products
Retrieve the Google IAP Product using the following function.

```dart
try {
  List<Object?> result = await Chargebee.retrieveProducts({productList: "[Product ID's from Google Play Console]"});
  log('result : ${result}');
} catch (e) {
print('CBException : ${e.message}');
  print(e);
}
            
```
You can present any of the above products to your users for them to purchase.

### Buy or Subscribe Product
Pass the product and customer identifiers to the following function when the user chooses the product to purchase.

customerId - Optional parameter. We need the unique ID of your customer as customerId. If your unique list of customers is maintained in your database or a third-party system, send us the unique ID from that source.

```dart
try {
  final result = await Chargebee.purchaseProduct(product, customerId);
  print("subscription result : $result");
}  catch (e) {
  print('Exception : ${e.toString()}');
}
 ```
The above function will handle the purchase against Google Play Store and send the IAP token for server-side token verification to your Chargebee account. Use the Subscription ID returned by the above function, to check for Subscription status on Chargebee and confirm the access - granted or denied.

### Get Subscription Status for Existing Subscribers
The following are methods for checking the subscription status of a subscriber who already purchased the product.

### Get Subscription Status for Existing Subscribers using Query Parameters
Use query parameters - Customer ID for checking the Subscription status on Chargebee and confirm the access - granted or denied.

```dart
try {
  subscriptionList = await Chargebee.retrieveSubscriptions(customerId);
  log('result : $subscriptionList');
}  catch (e) {
  print('Exception : ${e.toString()}');
}  
```
For example, query parameters can be passed as **"customer_id" : "id"**.

## License

Chargebee is available under the [MIT license](https://opensource.org/licenses/MIT). See the LICENSE file for more info.

