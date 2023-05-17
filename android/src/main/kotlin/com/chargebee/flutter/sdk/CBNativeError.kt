package com.chargebee.flutter.sdk

import com.android.billingclient.api.BillingClient

enum class CBNativeError(val code: Int) {
    // Restore Error
    SERVICE_TIMEOUT(2014),
    FEATURE_NOT_SUPPORTED(2015),
    SERVICE_UNAVAILABLE(2016),
    DEVELOPER_ERROR(2017),
    ERROR(2018),
    SERVICE_DISCONNECTED(2019),
    USER_CANCELED(2020),
    BILLING_UNAVAILABLE(2021),
    ITEM_UNAVAILABLE(2022),
    ITEM_NOT_OWNED(2023),
    ITEM_ALREADY_OWNED(2024),
    UNKNOWN(0);

    companion object {
        fun billingResponseCode(code: Int): CBNativeError {
            return when (code) {
                BillingClient.BillingResponseCode.SERVICE_TIMEOUT -> SERVICE_TIMEOUT
                BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED -> FEATURE_NOT_SUPPORTED
                BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE -> SERVICE_UNAVAILABLE
                BillingClient.BillingResponseCode.DEVELOPER_ERROR -> DEVELOPER_ERROR
                BillingClient.BillingResponseCode.ERROR -> ERROR
                BillingClient.BillingResponseCode.SERVICE_DISCONNECTED -> SERVICE_DISCONNECTED
                BillingClient.BillingResponseCode.USER_CANCELED -> USER_CANCELED
                BillingClient.BillingResponseCode.BILLING_UNAVAILABLE -> BILLING_UNAVAILABLE
                BillingClient.BillingResponseCode.ITEM_UNAVAILABLE -> ITEM_UNAVAILABLE
                BillingClient.BillingResponseCode.ITEM_NOT_OWNED -> ITEM_NOT_OWNED
                BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> ITEM_ALREADY_OWNED
                else -> UNKNOWN
            }
        }
    }
}
