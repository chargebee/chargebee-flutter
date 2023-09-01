package com.chargebee.flutter.sdk

import com.chargebee.android.exceptions.CBException
import org.json.JSONException
import org.json.JSONObject

fun CBException.messageUserInfo(): MutableMap<String, out Any?> {
  val messageUserInfo = mutableMapOf<String, Any?>()
  try {
    val jsonObject = JSONObject(this.message)
    messageUserInfo["message"] = jsonObject.optString("message")
    messageUserInfo["apiErrorCode"] = jsonObject.optString("api_error_code")
    messageUserInfo["httpStatusCode"] = jsonObject.optInt("http_status_code")
  } catch (e: JSONException) {
    messageUserInfo["message"] = this.message
  }
  return messageUserInfo
}