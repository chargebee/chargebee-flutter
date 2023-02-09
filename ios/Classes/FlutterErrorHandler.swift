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
import Chargebee
#endif

extension FlutterError {
    
    static func noArgsError() -> FlutterError{
        return FlutterError(code: "0",
                            message: "Could not find query params",
                            details: "Make sure you pass Map as query params")
    }

    static func chargebeeError(_ error: CBError) -> FlutterError {
        return FlutterError(code: error.httpStatusCode.description,
                            message: error.localizedDescription,
                            details: "Chargebee error")
    }
    
    static func purchaseError(_ error: CBPurchaseError) -> FlutterError {
        return FlutterError (code: error.skErrorCode.description,
                             message: error.localizedDescription,
                             details: "Request failed")
    }

    static func productIdentifierError(_ description: String) -> FlutterError {
        return FlutterError (code: "ProductIdentifier",
                             message: description,
                             details: "Request Failed")
    }

    static func jsonSerializationError(_ description: String) -> FlutterError {
        return FlutterError(code: "JSONSerialization",
                            message: description,
                            details: "JSON Serialization Error")
        
    }
}

extension CBPurchaseError {
    public var skErrorCode: Int {
        switch self {
        case .unknown: return 0
        case .invalidClient: return 1
        case .userCancelled: return 2
        case .paymentFailed: return 3
        case .paymentNotAllowed: return 4
        case .productNotAvailable: return 5
        case .cannotMakePayments: return 6
        case .networkConnectionFailed: return 7            
        case .productsNotFound: return 8
        case .privacyAcknowledgementRequired: return 9
        case .invalidOffer: return 11
        case .invalidPromoCode: return 12
        case .invalidPrice: return 14
        case .invalidPromoOffer: return 13
        case .invalidSandbox: return 8
        case .productIDNotFound: return 10
        case .skRequestFailed:return 15
        case .noProductToRestore:return 16
        case .invalidSDKKey:return 17
        case .invalidCustomerId:return 18
        case .invalidCatalogVersion:return 19
        case .invalidPurchase:return 20
        }
    }
}
