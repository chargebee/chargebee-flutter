package com.chargebee.flutter.sdk

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.chargebee.android.Chargebee
import com.chargebee.android.ProgressBarListener
import com.chargebee.android.billingservice.BillingClientManager
import com.chargebee.android.billingservice.CBCallback
import com.chargebee.android.billingservice.CBPurchase
import com.chargebee.android.exceptions.CBException
import com.chargebee.android.models.*
import com.chargebee.android.models.CBProduct.*
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class ChargebeeFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware{

    private lateinit var channel: MethodChannel
    var mItemsList = ArrayList<String>()
    var mPlansList = ArrayList<String>()
    var mSkuProductList = ArrayList<String>()
    var result: MethodChannel.Result? = null
    var mContext: Context? = null
    var subscriptionStatus = HashMap<String, Any>()

    private lateinit var context: Context
    private lateinit var activity: Activity


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "chargebee_flutter_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val args = call.arguments() as? Map<String, Any>?

        when (call.method) {
            "authentication" -> {
                if (args != null) {
                    authentication(args)
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
            else -> {
                Log.d(javaClass.simpleName, "Implementation not Found")
                result.notImplemented()
            }
        }

    }
    private fun authentication(args: Map<String, Any>) {
        val siteName = args["site_name"] as String
        val apiKey = args["api_key"] as String
        val sdkKey = args["sdk_key"] as String
        val packageName = args["package_name"] as String

        Log.i("ChargebeePlugIn", " $siteName, $apiKey, $sdkKey, package Name: ${activity.packageName}")
        // Configure with Chargebee SDK
        Chargebee.configure(site = siteName, publishableApiKey = apiKey, sdkKey = sdkKey, packageName = packageName)

    }

    private fun retrieveProducts(args: Map<String, Any>, result: Result) {
        val productIdList: ArrayList<String> = args["product_id"] as ArrayList<String>
        CBPurchase.retrieveProducts(
                activity,
                productIdList,
                object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                    override fun onSuccess(productDetails: ArrayList<CBProduct>) {
                        Log.i(javaClass.simpleName, "Product from Google Play Console:  $productDetails")
                        mSkuProductList.clear()
                        for (product in productDetails) {
                            val jsonMapString = Gson().toJson(product.toMap())
                            mSkuProductList.add(jsonMapString)
                        }
                        result.success(mSkuProductList)
                    }

                    override fun onError(error: CBException) {
                        Log.e(javaClass.simpleName, "Error:  ${error.message}")
                        result.success(error.message)
                    }
                })
    }

    private fun purchaseProduct(args: Map<String, Any>, result: Result) {
        var customerID = "";
        if (args["customerId"] != null) {
            customerID = args["customerId"] as String
        }
        val arrayList: ArrayList<String> = ArrayList<String>()
        arrayList.add(args["product"] as String)

        CBPurchase.retrieveProducts(
            activity,
            arrayList,
           object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                override fun onSuccess(productDetails: ArrayList<CBProduct>) {
                    Log.i(
                        javaClass.simpleName,
                        "Product from Google Play Console:  $productDetails"
                    )
                    CBPurchase.purchaseProduct(
                        productDetails.first(),
                        customerID,
                        object : CBCallback.PurchaseCallback<String> {
                            override fun onSuccess(subscriptionID: String, status: Boolean) {
                                Log.i(javaClass.simpleName, "Subscription ID:  $subscriptionID")
                                Log.i(javaClass.simpleName, "Status:  $status")
                                result.success(onResultMap(subscriptionID, "$status"))
                            }

                            override fun onError(error: CBException) {
                                Log.i(javaClass.simpleName, "Exception :${error.message}")
                                result.success(onResultMap("${error.message}", "${error.message}"))
                            }
                        })
                }

                override fun onError(error: CBException) {
                    Log.e(javaClass.simpleName, "Error:  ${error.message}")
                    result.success(onResultMap("${error.message}", "${error.message}"))
                }
            })
    }

    fun onResultMap(id: String, status: String): String{
        subscriptionStatus.put("id", id)
        subscriptionStatus.put("status", status)
        return Gson().toJson(subscriptionStatus)
    }
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivity() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

}

fun CBProduct.toMap(): Map<String, Any> {
    return mapOf(
        "productId" to productId,
        "productPrice" to productPrice,
        "productTitle" to productTitle
    )
}

