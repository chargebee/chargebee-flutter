package com.chargebee.example

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.chargebee.android.Chargebee
import com.chargebee.android.billingservice.CBCallback
import com.chargebee.android.billingservice.CBPurchase
import com.chargebee.android.exceptions.CBException
import com.chargebee.android.exceptions.ChargebeeResult
import com.chargebee.android.models.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.*
import com.chargebee.android.models.CBProduct.*
import com.google.gson.Gson
import com.android.billingclient.api.SkuDetails

class ChargebeeFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    var mItemsList = ArrayList<String>()
    var mPlansList = ArrayList<String>()
    var mSkuProductList = ArrayList<String>()
    var result: MethodChannel.Result? = null
    var mContext: Context? = null
    var subscriptionStatus = HashMap<String,Any>()

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
                if(args != null){
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
        Log.i("ChargebeePlugIn", " $siteName, $apiKey, $sdkKey, ${activity.packageName}")
        // Configure with Chargebee SDK
        Chargebee.configure(site = siteName, publishableApiKey = apiKey, sdkKey = sdkKey, packageName = activity.packageName)
    }

    private fun retrieveProducts(args: Map<String, Any>, result: Result) {
        val productIdList: ArrayList<String> = args["product_id"] as ArrayList<String>

        Log.i(javaClass.simpleName, "productIdList:  $productIdList")

        CBPurchase.retrieveProducts(
                activity,
                productIdList,
                object : CBCallback.ListProductsCallback<ArrayList<CBProduct>> {
                    override fun onSuccess(productDetails: ArrayList<CBProduct>) {

                        Log.e(javaClass.simpleName, "productDetails:  $productDetails")
                        mSkuProductList.clear()

                        for (product in productDetails) {
                            val jsonString = Gson().toJson(product)
                            Log.e(javaClass.simpleName, "jsonString:  $jsonString")

//                            val cbProducts = CBProducts(product.productId,product.productTitle,product.skuDetails )
//                            val skuProduct = mapOf<String, Any>("productId" to product.productId,
//                                    "productTitle" to product.productTitle )

                            mSkuProductList.add(jsonString)
                        }

                        result.success(mSkuProductList)
                    }

                    override fun onError(error: CBException) {
                        Log.e(javaClass.simpleName, "Error:  ${error.message}")

                    }
                })
    }

    private fun purchaseProduct(args: Map<String, Any>, result: Result ) {

        val product: Map<String, Any> = args["product"] as Map<String, Any>
        var customerID = "";
        if (product.get("customerId")  !=null) {
             customerID = product.get("customerId") as String
        }
       // Log.i(javaClass.simpleName, "Customer ID:  $customerID")
        val skuDetailsFromFlutter: String = product.get("skuDetails").toString()

       // Log.i(javaClass.simpleName, "skuDetailsFromFlutter:  $skuDetailsFromFlutter")

        val skuDetails = SkuDetails(skuDetailsFromFlutter)

        val cbProduct = CBProduct(
                skuDetails.sku,
                skuDetails.title,
                skuDetails.price,
                skuDetails,
                false
        )
        CBPurchase.purchaseProduct(cbProduct, customerID,  object : CBCallback.PurchaseCallback<String>{
            override fun onSuccess(subscriptionID: String, status:Boolean) {
                Log.i(javaClass.simpleName, "Subscription ID:  $subscriptionID")
                subscriptionStatus.put("subscriptionId", subscriptionID)
                subscriptionStatus.put("status", status)

                result.success(subscriptionStatus)
            }
            override fun onError(error: CBException) {

                Log.i(javaClass.simpleName, "Exception :${error.message}")
            }
        })
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
