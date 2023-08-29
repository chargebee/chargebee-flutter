package com.chargebee.flutter.sdk

import com.android.billingclient.api.BillingClient

enum class CBNativeError(val code: Int) {

    UNKNOWN(0),

    // Chargebee Errors
    INVALID_SDK_CONFIGURATION(1000),
    INVALID_CATALOG_VERSION(1001),

    // Store Errors
    INVALID_OFFER(2001),
    INVALID_PURCHASE(2002),
    INVALID_SANDBOX(2003),
    NETWORK_ERROR(2004),
    PAYMENT_FAILED(2005),
    PAYMENT_NOT_ALLOWED(2006),
    PRODUCT_NOT_AVAILABLE(2007),
    PURCHASE_NOT_ALLOWED(2008),
    PURCHASE_CANCELLED(2009),
    STORE_PROBLEM(2010),
    INVALID_RECEIPT(2011),
    REQUEST_FAILED(2012),
    PRODUCT_PURCHASED_ALREADY(2013);

    companion object {
        fun billingResponseCode(code: Int): CBNativeError {
            return when (code) {
                BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED, BillingClient.BillingResponseCode.BILLING_UNAVAILABLE, BillingClient.BillingResponseCode.ITEM_NOT_OWNED -> PURCHASE_NOT_ALLOWED
                BillingClient.BillingResponseCode.ERROR, BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE, BillingClient.BillingResponseCode.SERVICE_DISCONNECTED, BillingClient.BillingResponseCode.SERVICE_TIMEOUT -> STORE_PROBLEM
                BillingClient.BillingResponseCode.USER_CANCELED -> PURCHASE_CANCELLED
                BillingClient.BillingResponseCode.ITEM_UNAVAILABLE -> PRODUCT_NOT_AVAILABLE
                BillingClient.BillingResponseCode.DEVELOPER_ERROR -> INVALID_PURCHASE
                BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> PRODUCT_PURCHASED_ALREADY
                else -> UNKNOWN
            }
        }
    }
}
