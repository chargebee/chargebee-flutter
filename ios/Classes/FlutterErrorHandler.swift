//
//  FlutterErrorHandler.swift
//  chargebee_flutter_sdk
//
//  Created by Amutha C on 20/04/22.
//

import Foundation
#if canImport(FlutterMacOS)
import FlutterMacOS
#else
import Flutter
#endif

extension FlutterError {
  static private let passValidValue = "Please make sure you pass a valid value"
  
  static let noArgs = FlutterError(code: "0",
                                   message: "Could not find call arguments",
                                   details: "Make sure you pass Map as call arguments")
  
  static let noApiKey = FlutterError(code: "1",
                                     message: "Could not find API key",
                                     details: passValidValue)
  
  static let noCustomerId = FlutterError(code: "2",
                                     message: "Could not find noCustomerId",
                                     details: passValidValue)
  
  static let noAutoTrackPurchases = FlutterError(code: "3",
                                                 message: "Could not find autoTrackPurchases boolean value",
                                                 details: passValidValue)
  
  static let noData = FlutterError(code: "4",
                                   message: "Could not find data",
                                   details: passValidValue)
  
  static let noProvider = FlutterError(code: "5",
                                       message: "Could not find provider",
                                       details: passValidValue)
  
  static func failedToGetProducts(_ error: NSError) -> FlutterError {
    return mapChargebeeError(error, errorCode: "7", errorMessage: "Failed to get products")
  }
  
  static let noProductId = FlutterError(code: "8",
                                        message: "Could not find productId value",
                                        details: "Please provide valid productId")
  
  static let noProduct = FlutterError(code: "ProductNotProvided",
                                      message: "Could not find product",
                                      details: "Please provide a valid product")
  
  static func chargebeeError(_ error: NSError) -> FlutterError {
    return mapChargebeeError(error, errorCode: "9")
  }
  
  static func parsingError(_ description: String) -> FlutterError {
    return FlutterError(code: "12",
                        message: "Arguments Parsing Error",
                        details: description)
  }
  

  static let noPropertyValue = FlutterError(code: "14",
                                            message: "Could not find property value",
                                            details: passValidValue)
  
 
  static let noSdkInfo = FlutterError(code: "15",
                                      message: "Could not find sdk info",
                                      details: passValidValue)
  
  static func promoPurchaseError(_ productId: String) -> FlutterError {
    return FlutterError (code: "PromoPurchase",
                         message: "Could not find completion block for Product ID: \(productId)",
                         details: passValidValue)
  }
  
  static func jsonSerializationError(_ description: String) -> FlutterError {
    return FlutterError(code: "JSONSerialization",
                        message: "JSON Serialization Error",
                        details: description)
    
  }
  
  
  private static func mapChargebeeError(_ error: NSError, errorCode: String, errorMessage: String? = nil) -> FlutterError {
    var message = ""
    
    if let errorMessage = errorMessage {
      message = errorMessage + ". "
    }
    message += error.localizedDescription
    
    var details = "Chargebee Error Code: \(error.code)"
    
    if let additionalMessage = error.userInfo[NSDebugDescriptionErrorKey] {
      details = "\(details). Additional Message: \(additionalMessage)"
    }
    
    return FlutterError(code: errorCode,
                        message: message,
                        details: details)
  }
}

