import 'package:flutter/services.dart';

enum ChargebeeError {
  unknown(0),
  invalidSDKConfiguration(1000),
  invalidCatalogVersion(1001),
  cannotMakePayments(1002),
  invalidResource(1003),
  invalidOffer(2001),
  invalidPurchase(2002),
  invalidSandbox(2003),
  networkError(2004),
  paymentFailed(2005),
  paymentNotAllowed(2006),
  productNotAvailable(2007),
  purchaseNotAllowed(2008),
  purchaseCancelled(2009),
  storeProblem(2010),
  invalidReceipt(2011),
  requestFailed(2012),
  productPurchasedAlready(2013),
  noReceipt(2014),
  refreshReceiptFailed(2015),
  restoreFailed(2016),
  invalidReceiptURL(2017),
  invalidReceiptData(2018),
  noProductToRestore(2019),
  serviceError(2020),
  systemError(3000);

  final int errorCode;
  const ChargebeeError(this.errorCode);
}

class ChargebeeErrorHelper {
  static ChargebeeError getErrorCode(PlatformException e) {
    final errorCode = int.parse(e.code);
    if (errorCode >= ChargebeeError.values.length) {
      return ChargebeeError.unknown;
    }
    return ChargebeeError.values[errorCode];
  }
}
