## 0.2.0
New Feature
* Introduced new API `purchaseStoreProduct` to purchase product with customer information. (#68)
## 0.1.0
New Feature
* Adds show manage subscriptions settings in app (#67)
## 0.0.14
New Feature
* Adds one time purchase support. (#64)
* Use `Chargebee.purchaseNonSubscriptionProduct` to purchase one time purchase product on Apple App Store and Google Play Store.
* Use `Chargebee.validateReceiptForNonSubscriptions` to validate one time purchase receipt if syncing failed with Chargebee after the successful purchase on Apple App Store and Google
  Play Store.
## 0.0.13
SDK Improvements
* Added cache retry mechanism for validating the receipt. (#62)
* Use `Chargebee.validateReceipt` to validate the receipt if syncing failed with Chargebee after the successful purchase on Apple App Store and Google
  Play Store.
## 0.0.12
New Feature
* Added restore purchases (#61)
## 0.0.11
SDK Improvements
* Package `utils` renamed to `models` and Added sdk method `retrieveProductIdentifiers` instead of `retrieveProductIdentifers` (#52)
* Removed `dynamic` object for all API methods and updated with appropriate data type (#50)
* Standardize the dart documentation for the API's (#57)
* Added `CBEntitlement` model to showcase list of entitlements instead of dynamic list and improvements (#58)
* Unit test added for the API `retrieveProducts` and `purchaseProduct` (#58)
* Added integration test (#56)
* Added linting support (#53)
## 0.0.10
Bug fixes
* Additional information added to Product model (#45) 
* Android plugIn improved by removing un-wanted try-catch blocks around the purchaseProduct and empty checks on the product. SubscriptionId and planId made as non-optional to avoid Optional type (#48)
* Improvements on error handling, Added appropriate error codes to PlatformException. No impacts on existing error handling logic (#49) 
## 0.0.9
Bug fixes
* flutter retrieve all plans issue - Response has no/invalid body. And the issue fixed in Native iOS SDK v1.0.17
* Added configure() method callbacks to handle error case if any errors thrown from Chargebee during configuration
  Fixed in this PR - https://github.com/chargebee/chargebee-ios/pull/56 and https://github.com/chargebee/chargebee-ios/pull/55
## 0.0.8
Bug fixes
* Android app crashed on signed apk and the issue fixed in Native Android SDK v1.0.15
## 0.0.7
Bug fixes
  * Android flutter sdk error type mismatch: inferred type is String? but String was expected. 
    The issue has been fixed in this PR - https://github.com/chargebee/chargebee-flutter/pull/33
## 0.0.6
Bug fixes
  * subscriptionId is not set on android #28
  * App Crash After Purchase Subscriptions #11
  * retrieveSubscriptions and retrieveAllItems should not crash if there are no subs/items #27
  * Return type of retrieveProductIdentifers #25
  * nullpointer exception #24
  * Chargebee.configure never finishes on error #23
  * Don't just swallow exceptions #26
  * Updated Readme.md file
## 0.0.5
Bug fixes
  * Swift Compiler Error (Xcode): Cannot find 'Environment' in scope
  * Error while integrating iOS Flutter SDK
  * Updated Readme.md file
## 0.0.4
* Bug fixes
## 0.0.3
* Added support for retrieve product identifiers, entitlements, plans and items.
## 0.0.2
* Minor updates on documentation
## 0.0.1
* Release 0.0.1

