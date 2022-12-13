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
    
    static func subscriptionError(_ description: String)-> FlutterError{
        return FlutterError(code: "404",
                            message: "Failed",
                            details: description)
    }
    static func noArgsError() -> FlutterError{
        return FlutterError(code: "0",
                            message: "Could not find query params",
                            details: "Make sure you pass Map as query params")
    }
    static func chargebeeError(_ error: NSError) -> FlutterError {
        return mapChargebeeError(error)
    }
    
    static func purchaseError(_ description: String) -> FlutterError {
        return FlutterError (code: "Purchase",
                             message: "Failed",
                             details: description)
    }
    static func jsonSerializationError(_ description: String) -> FlutterError {
        return FlutterError(code: "JSONSerialization",
                            message: "JSON Serialization Error",
                            details: description)
        
    }
    static func productError(_ description: String) -> FlutterError {
        return FlutterError(code: "ProductNotFound",
                            message: "Could not find product",
                            details: description)
    }
    private static func mapChargebeeError(_ error: NSError, errorCode: String?=nil, errorMessage: String? = nil) -> FlutterError {
        var message = ""
        
        if let errorMessage = errorMessage {
            message = errorMessage + ". "
        }
        message += error.localizedDescription
        
        var details = "Chargebee Error Code: \(error.code)"
        
        if let additionalMessage = error.userInfo[NSDebugDescriptionErrorKey] {
            details = "\(details). Additional Message: \(additionalMessage)"
        }
        
        return FlutterError(code: errorCode ?? "",
                            message: message,
                            details: details)
    }
}

