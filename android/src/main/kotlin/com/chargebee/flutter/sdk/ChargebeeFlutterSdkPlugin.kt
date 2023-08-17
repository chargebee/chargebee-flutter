package com.chargebee.flutter.sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.chargebee.android.Chargebee
import com.chargebee.android.ErrorDetail
import com.chargebee.android.billingservice.*
import com.chargebee.android.network.CBAuthResponse
import com.chargebee.android.exceptions.CBException
import com.chargebee.android.exceptions.CBProductIDResult
import com.chargebee.android.exceptions.ChargebeeResult
import com.chargebee.android.models.*
import com.chargebee.android.network.CBCustomer
import com.chargebee.android.network.ReceiptDetail
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class ChargebeeFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    var mItemsList = ArrayList<String>()
    var mPlansList = ArrayList<String>()
    var mSkuProductList = ArrayList<String>()
    var result: MethodChannel.Result? = null
    var mContext: Context? = null
    var subscriptionStatus = HashMap<String, Any>()
    var subscriptionsList = ArrayList<String>()
    private lateinit var context: Context
    private lateinit var activity: Activity
    var queryParam = arrayOf<String>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "chargebee_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val args = call.arguments() as? Map<String, Any>?

        when (call.method) {
            "authentication" -> {
                if (args != null) {
                    authentication(args, result)
                }
            }
            "getProducts" -> {
                if (args != null) {
                    retrieveProducts(args, result)
                }
            }
            "purchaseProduct" -> {
                if (args != null) {
                    purchaseProduct(args, result)
                }
            }
            "showManageSubscriptionsSettings" -> {
                showManageSubscriptionsSettings(args)
            }
            "purchaseNonSubscriptionProduct" -> {
                if (args != null) {
                    purchaseNonSubscriptionProduct(args, result)
                }
            }
            "retrieveSubscriptions" -> {
                val params = call.arguments() as? Map<String, String>?
                if (params != null) {
                    retrieveSubscriptions(params, result)
                }
            }
            "retrieveAllItems" -> {
                val params = call.arguments() as? Map<String, String>?
                if (params != null) {
                    retrieveAllItems(params, result)
                }
            }
            "retrieveAllPlans" -> {
                val params = call.arguments() as? Map<String, String>?
                retrieveAllPlans(params, result)
            }
            "retrieveProductIdentifiers" -> {
                val params = call.arguments() as? Map<String, String>?
                retrieveProductIdentifiers(params, result)
            }
            "retrieveEntitlements" -> {
                val params = call.arguments() as? Map<String, String>?
                if (params != null) {
                    retrieveEntitlements(params, result)
                }
            }
            "restorePurchases" -> {
                val params = call.arguments() as? Map<String, Boolean>?
                restorePurchases(result, params)
            }
            "validateReceipt" -> {
                if (args != null) {
                    validateReceipt(args, result)
                }
            }
            "validateReceiptForNonSubscriptions" -> {
                if (args != null) {
                    validateReceiptForNonSubscriptions(args, result)
                }
            }
            else -> {
                Log.d(javaClass.simpleName, "Implementation not Found")
                result.notImplemented()
            }
        }
    }

    private fun authentication(args: Map<String, Any>, result: Result) {
        val siteName = args["site_name"] as String
        val apiKey = args["api_key"] as String
        val sdkKey = args["sdk_key"] as String
        // Added chargebee logger support for flutter android sdk
        Chargebee.environment = "cb_flutter_android_sdk"
        // Configure with Chargebee SDK
        Chargebee.configure(
            site = siteName,
            publishableApiKey = apiKey,
            sdkKey = sdkKey,
            packageName = "${activity.packageName}"
        ) {
            when (it) {
                is ChargebeeResult.Success -> {
                    val response = (it.data) as CBAuthResponse
                    result.success(response.in_app_detail.status)
                }
                is ChargebeeResult.Error -> {
                    onError(it.exp, result)
                }
            }
        }
    }

    private fun retrieveProducts(args: Map<String, Any>, result: Result) {
        val productIdList: ArrayList<String> = args["product_id"] as ArrayList<String>
        CBPurchase.retrieveProducts(
            activity,
            productIdList,
            object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                override fun onSuccess(productDetails: ArrayList<CBProduct>) {
                    mSkuProductList.clear()
                    for (product in productDetails) {
                        val jsonMapString = Gson().toJson(product.toMap())
                        mSkuProductList.add(jsonMapString)
                    }
                    result.success(mSkuProductList)
                }

                override fun onError(error: CBException) {
                    onError(error, result)
                }
            })
    }

    private fun restorePurchases(resultCallback: Result, queryParams: Map<String, Boolean>?) {
        val includeInactivePurchases = queryParams?.get("includeInactivePurchases") as Boolean
        CBPurchase.restorePurchases(
            activity,
            includeInactivePurchases,
            object : CBCallback.RestorePurchaseCallback {
                override fun onSuccess(result: List<CBRestoreSubscription>) {
                    val restoreSubscription = result.map { subscription ->
                        Gson().toJson(subscription.toMap())
                    }
                    resultCallback.success(restoreSubscription)
                }

                override fun onError(error: CBException) {
                    onStoreError(error, resultCallback)
                }
            })
    }

    private fun purchaseProduct(args: Map<String, Any>, result: Result) {
        val customerID = args["customerId"] as String
        val arrayList: ArrayList<String> = ArrayList<String>()
        arrayList.add(args["product"] as String)
        CBPurchase.retrieveProducts(
            activity,
            arrayList,
            object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                override fun onSuccess(productIDs: ArrayList<CBProduct>) {
                    if (productIDs.size == 0) {
                        onError(
                            CBException(ErrorDetail(GPErrorCode.ProductUnavailable.errorMsg)),
                            result
                        )
                        return
                    }
                    CBPurchase.purchaseProduct(
                        productIDs.first(),
                        customerID,
                        object : CBCallback.PurchaseCallback<String> {
                            override fun onSuccess(
                                receiptDetail: ReceiptDetail,
                                status: Boolean
                            ) {
                                result.success(
                                    onResultMap(
                                        receiptDetail.subscription_id,
                                        receiptDetail.plan_id,
                                        receiptDetail.customer_id,
                                        "$status"
                                    )
                                )
                            }

                            override fun onError(error: CBException) {
                                onError(error, result)
                            }
                        })
                }

                override fun onError(error: CBException) {
                    onError(error, result)
                }
            })
    }

    private fun showManageSubscriptionsSettings(args: Map<String, Any>?) {
        val productId = args?.get("productId") as String
        val packageName = args?.get("applicationId") as String
        Chargebee.showManageSubscriptionsSettings(context = activity, productId = productId, packageName = packageName)
    }

    private fun purchaseNonSubscriptionProduct(args: Map<String, Any>, callback: Result) {
        val customer = CBCustomer(
            args["customerId"] as String,
            args["firstName"] as String,
            args["lastName"] as String,
            args["email"] as String
        )
        val type = args["product_type"] as String
        val productType = if (type == OneTimeProductType.CONSUMABLE.value)
            OneTimeProductType.CONSUMABLE
        else
            OneTimeProductType.NON_CONSUMABLE

        val product = arrayListOf(args["product"] as String)
        CBPurchase.retrieveProducts(
            activity,
            product,
            object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                override fun onSuccess(productIDs: ArrayList<CBProduct>) {
                    if (productIDs.size == 0) {
                        onError(
                            CBException(ErrorDetail(GPErrorCode.ProductUnavailable.errorMsg)),
                            callback
                        )
                        return
                    }
                    CBPurchase.purchaseNonSubscriptionProduct(
                        productIDs.first(),
                        customer,
                        productType,
                        object : CBCallback.OneTimePurchaseCallback {
                            override fun onSuccess(result: NonSubscription, status: Boolean) {
                                callback.success(result.toMap())
                            }

                            override fun onError(error: CBException) {
                                onError(error, callback)
                            }
                        })
                }

                override fun onError(error: CBException) {
                    onError(error, callback)
                }
            })
    }

    private fun onResultMap(
        id: String, planId: String, customerId: String, status: String
    ): String {
        subscriptionStatus["subscriptionId"] = id
        subscriptionStatus["planId"] = planId
        subscriptionStatus["customerId"] = customerId
        subscriptionStatus["status"] = status
        return Gson().toJson(subscriptionStatus)
    }

    private fun retrieveSubscriptions(queryParams: Map<String, String> = mapOf(), result: Result) {
        Chargebee.retrieveSubscriptions(queryParams) {
            when (it) {
                is ChargebeeResult.Success -> {
                    val listSubscriptions = (it.data as CBSubscription).list
                    val jsonString = Gson().toJson(listSubscriptions)

                    result.success(jsonString)
                }
                is ChargebeeResult.Error -> {
                    onError(it.exp, result)
                }
            }
        }

    }

    private fun retrieveAllItems(queryParams: Map<String, String>? = mapOf(), result: Result) {
        if (queryParams != null)
            queryParam = arrayOf(
                queryParams["limit"] ?: "",
                queryParams["sort_by[desc]"] ?: "Standard",
                Chargebee.channel
            )

        Chargebee.retrieveAllItems(queryParam) {
            when (it) {
                is ChargebeeResult.Success -> {
                    val jsonString = Gson().toJson((it.data as ItemsWrapper).list)
                    result.success(jsonString)
                }
                is ChargebeeResult.Error -> {
                    onError(it.exp, result)
                }
            }
        }
    }

    private fun retrieveAllPlans(queryParams: Map<String, String>? = mapOf(), result: Result) {
        if (queryParams != null)
            queryParam = arrayOf(
                queryParams["limit"] ?: "",
                queryParams["sort_by[desc]"] ?: "Standard",
                Chargebee.channel
            )

        Chargebee.retrieveAllPlans(queryParam) {
            when (it) {
                is ChargebeeResult.Success -> {
                    val jsonString = Gson().toJson((it.data as PlansWrapper).list)
                    result.success(jsonString)
                }
                is ChargebeeResult.Error -> {
                    onError(it.exp, result)
                }
            }
        }
    }

    private fun retrieveProductIdentifiers(
        queryParams: Map<String, String>? = mapOf(),
        result: Result
    ) {
        if (queryParams != null)
            queryParam = arrayOf(queryParams["limit"] ?: "")
        CBPurchase.retrieveProductIdentifers(queryParam) {
            when (it) {
                is CBProductIDResult.ProductIds -> {
                    if (it.IDs.isNotEmpty()) {
                        val jsonString = Gson().toJson(it.IDs)
                        result.success(jsonString)
                    }
                }
                is CBProductIDResult.Error -> {
                    onError(it.exp, result)
                }
            }
        }
    }

    private fun retrieveEntitlements(queryParams: Map<String, String>, result: Result) {
        val subscriptionId = queryParams["subscriptionId"] as String
        Chargebee.retrieveEntitlements(subscriptionId) {
            when (it) {
                is ChargebeeResult.Success -> {
                    if ((it.data as CBEntitlements).list.isNotEmpty()) {
                        val jsonString = Gson().toJson((it.data as CBEntitlements).list)
                        result.success(jsonString)
                    }
                }
                is ChargebeeResult.Error -> {
                    onError(it.exp, result)
                }
            }
        }
    }

    private fun validateReceipt(args: Map<String, Any>, result: Result) {
        val customer = CBCustomer(
            args["customerId"] as String,
            args["firstName"] as String,
            args["lastName"] as String,
            args["email"] as String
        )
        val arrayList: ArrayList<String> = ArrayList<String>()
        arrayList.add(args["product"] as String)
        CBPurchase.retrieveProducts(activity,
            arrayList,
            object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                override fun onSuccess(productIDs: ArrayList<CBProduct>) {
                    if (productIDs.size == 0) {
                        onError(
                            CBException(ErrorDetail(GPErrorCode.ProductUnavailable.errorMsg)),
                            result
                        )
                        return
                    }
                    CBPurchase.validateReceipt(context = activity,
                        product = productIDs.first(),
                        customer = customer,
                        completionCallback = object : CBCallback.PurchaseCallback<String> {
                            override fun onSuccess(
                                receiptDetail: ReceiptDetail, status: Boolean
                            ) {
                                result.success(
                                    onResultMap(
                                        receiptDetail.subscription_id,
                                        receiptDetail.plan_id,
                                        receiptDetail.customer_id,
                                        "$status"
                                    )
                                )
                            }

                            override fun onError(error: CBException) {
                                onError(error, result)
                            }
                        })
                }

                override fun onError(error: CBException) {
                    onError(error, result)
                }
            })
    }

    private fun validateReceiptForNonSubscriptions(args: Map<String, Any>, callback: Result) {
        val customer = CBCustomer(
            args["customerId"] as String,
            args["firstName"] as String,
            args["lastName"] as String,
            args["email"] as String
        )
        val type = args["product_type"] as String
        val productType = if (type == OneTimeProductType.CONSUMABLE.value)
            OneTimeProductType.CONSUMABLE
        else
            OneTimeProductType.NON_CONSUMABLE

        val product = arrayListOf(args["product"] as String)
        CBPurchase.retrieveProducts(activity,
            product,
            object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                override fun onSuccess(productIDs: ArrayList<CBProduct>) {
                    if (productIDs.size == 0) {
                        onError(
                            CBException(ErrorDetail(GPErrorCode.ProductUnavailable.errorMsg)),
                            callback
                        )
                        return
                    }
                    CBPurchase.validateReceiptForNonSubscriptions(context = activity,
                        product = productIDs.first(),
                        customer = customer,
                        productType = productType,
                        object : CBCallback.OneTimePurchaseCallback {
                            override fun onSuccess(result: NonSubscription, status: Boolean) {
                                callback.success(result.toMap())
                            }

                            override fun onError(error: CBException) {
                                onError(error, callback)
                            }
                        })
                }

                override fun onError(error: CBException) {
                    onError(error, callback)
                }
            })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding);
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    private fun onError(error: CBException, result: Result) {
        error("${error.httpStatusCode}", error, result)
    }

    private fun onStoreError(error: CBException, result: Result) {
        val errorCode = error.httpStatusCode?.let { CBNativeError.billingResponseCode(it).code }
        error("$errorCode", error, result)
    }

    private fun error(errorCode: String, error: CBException, result: Result) {
        try {
            result.error(
                errorCode, "${
                    Gson().fromJson(
                        error.message,
                        ErrorDetail::class.java
                    ).message
                }", error.localizedMessage
            )
        } catch (exp: Exception) {
            result.error(errorCode, "${error.message}", error.localizedMessage)
        }
    }
}

fun CBProduct.toMap(): Map<String, Any> {
    return mapOf(
        "productId" to productId,
        "productPrice" to convertPriceAmountInMicros(),
        "productPriceString" to productPrice,
        "productTitle" to productTitle,
        "currencyCode" to skuDetails.priceCurrencyCode,
        "subscriptionPeriod" to subscriptionPeriod()
    )
}

fun CBProduct.convertPriceAmountInMicros(): Double {
    return skuDetails.priceAmountMicros / 1_000_000.0
}

fun CBProduct.subscriptionPeriod(): Map<String, Any> {
    val subscriptionPeriodMap = if (skuDetails.type == ProductType.SUBS.value) {
        val subscriptionPeriod = skuDetails.subscriptionPeriod
        val numberOfUnits = subscriptionPeriod.substring(1, subscriptionPeriod.length - 1).toInt()
        mapOf(
            "periodUnit" to periodUnit(),
            "numberOfUnits" to numberOfUnits
        )
    } else {
        mapOf(
            "periodUnit" to "",
            "numberOfUnits" to 0
        )
    }
    return subscriptionPeriodMap
}

fun CBProduct.periodUnit(): String {
    return when (skuDetails.subscriptionPeriod.last().toString()) {
        "Y" -> "year"
        "M" -> "month"
        "W" -> "week"
        "D" -> "day"
        else -> ""
    }
}

internal fun CBRestoreSubscription.toMap(): Map<String, String> {
    return mapOf(
        "subscriptionId" to subscriptionId,
        "planId" to planId,
        "storeStatus" to storeStatus,
    )
}

internal fun NonSubscription.toMap(): String {
    val resultMap = mapOf(
        "invoiceId" to invoiceId,
        "chargeId" to chargeId,
        "customerId" to customerId,
    )
    return Gson().toJson(resultMap)
}
