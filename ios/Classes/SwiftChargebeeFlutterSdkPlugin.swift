import Flutter
import UIKit
import Chargebee
import StoreKit

public class SwiftChargebeeFlutterSdkPlugin: NSObject, FlutterPlugin {
    private var plans: [CBPlan] = []
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "chargebee_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftChargebeeFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result _result: @escaping FlutterResult) {
        
        switch call.method {
        case "authentication":
            guard let args = call.arguments as? [String: Any] else {
                return _result(FlutterError.noArgsError)
            }
            Chargebee.environment = "cb_flutter_ios_sdk"
            Chargebee.configure(site: args["site_name"] as! String,
                                apiKey: args["api_key"] as! String,
                                sdkKey: (args["sdk_key"] as! String))
        case "retrieveSubscriptions":
            guard let args = call.arguments as? [String: String] else {
                return _result(FlutterError.noArgsError)
            }

            Chargebee.shared.retrieveSubscriptions(queryParams: args) { result in
                switch result {
                case let .success(list):
                    if let data = try? JSONSerialization.data(
                        withJSONObject:list.compactMap { $0.dict },
                        options: []) {
                        if let jsonString = String(data: data,
                                                   encoding: .utf8) {
                            _result(jsonString)
                        }
                    }else {
                       
                        _result(FlutterError.subscriptionError("Serialization Issue"))
                    }
                case let .error(error):
                    _result(FlutterError.chargebeeError(error as NSError))
                }
            }
        case "purchaseProduct":
            guard let params = call.arguments as?  [String: String] else {
                return _result(FlutterError.noArgsError)
            }
            let productId = params["product"]
            let customerId = params["customerId"]
            
            CBPurchase.shared.retrieveProducts(withProductID: [productId!], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        debugPrint("products: \(products)");
                        let  product: CBProduct = products.self.first!;
                        CBPurchase.shared.purchaseProduct(product: product, customerId: customerId) { result in
                            switch result {
                            case .success(let result):
                                let dict = ["status": "\(result.status)", "subscriptionId": "\(result.subscriptionId)", "planId": "\(result.planId)"]
                                if let data = try? JSONSerialization.data(
                                    withJSONObject:dict,
                                    options: []) {
                                    if let jsonString = String(data: data,
                                                               encoding: .ascii) {
                                        _result(jsonString)
                                    }
                                }else {
                                    _result(FlutterError.jsonSerializationError("Serialization Issue"))
                                }
                            case .failure(let error):
                                _result(FlutterError.purchaseError(error.localizedDescription))
                            }
                        }
                    case let .failure(error):
                        _result(FlutterError.productError(error.localizedDescription))
                    }
                }
            })
            
        case "getProducts":
            guard let args = call.arguments as? [String: Any] else {
                return _result(FlutterError.noArgsError)
            }
            
            let productId = args["product_id"]
            CBPurchase.shared.retrieveProducts(withProductID: productId as! [String], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        debugPrint("products: \(products)");
                        var array = [String]()
                        for product in products {
                            if let theJSONData = try? JSONSerialization.data(
                                withJSONObject: product.product.toMap(),
                                options: []) {
                                if let jsonString = String(data: theJSONData,
                                                           encoding: .ascii) {
                                    array.append(jsonString)
                                }
                            }
                        }
                        _result(array)
                    case let .failure(error):
                        _result(FlutterError.productError(error.localizedDescription))
                    }
                }
            })
        case "retrieveProductIdentifers":
            let params = call.arguments as? [String: String]
            CBPurchase.shared.retrieveProductIdentifers(queryParams: params, completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(dataWrapper):
                       if let data = try? JSONSerialization.data(
                            withJSONObject:dataWrapper.ids,
                            options: []) {
                            if let jsonString = String(data: data,
                                                       encoding: .ascii) {
                                _result(jsonString)
                            }
                        }else {
                            _result(FlutterError.jsonSerializationError("Serialization Issue"))
                        }
                    case let .failure(error):
                        _result(FlutterError.chargebeeError(error as NSError))
                    }
                }
            })
        case "retrieveEntitlements":
            guard let args = call.arguments as? [String: String] else {
                return _result(FlutterError.noArgsError)
            }
            var subscriptionId = args["subscriptionId"]
            Chargebee.shared.retrieveEntitlements(forSubscriptionID: subscriptionId ?? "AzZlGJTC9U3tw4nF") { result in
                switch result {
                case let .success(entitlements):
                    if let data = try? JSONSerialization.data(
                        withJSONObject:entitlements.list.compactMap { $0.dict },
                        options: []) {
                        if let jsonString = String(data: data,
                                                   encoding: .ascii) {
                            _result(jsonString)
                        }
                    }else {
                        _result(FlutterError.jsonSerializationError("Serialization Issue"))
                    }
                case let .error(error):
                    _result(FlutterError.chargebeeError(error as NSError))
                }
            }
        case "retrieveAllItems":
            let params = call.arguments as? [String: String]
            print("All items:")
            Chargebee.shared.retrieveAllItems(queryParams: params, completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(itemLst):
                        if let data = try? JSONSerialization.data(
                            withJSONObject:itemLst.list.compactMap { $0.dict },
                            options: []) {
                            if let jsonString = String(data: data,
                                                       encoding: .utf8) {
                                _result(jsonString)
                            }
                        }else {
                            _result(FlutterError.jsonSerializationError("Serialization Issue"))
                        }
                    case let .error(error):
                        _result(FlutterError.chargebeeError( error as NSError))
                    }
                }
            })
        case "retrieveAllPlans":
            let params = call.arguments as? [String: String]
            print("List All Plans")
            Chargebee.shared.retrieveAllPlans(queryParams: params) { result in
                switch result {
                case let .success(plansList):
                    if let data = try? JSONSerialization.data(
                        withJSONObject:plansList.list.compactMap { $0.dict },
                        options: []) {
                        if let jsonString = String(data: data,
                                                   encoding: .utf8) {
                            _result(jsonString)
                        }
                    }else {
                        _result(FlutterError.jsonSerializationError("Serialization Issue"))
                    }
                case let .error(error):
                    _result(FlutterError.chargebeeError( error as NSError))
                }
            }
        default:
            print("Default statement")
        }
    }
}

extension Encodable {
    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}

extension SKProduct {
    func toMap() -> [String: Any?] {
        let map: [String: Any?] = [
            "productId": productIdentifier,
            "productPrice": price.description,
            "productTitle": localizedTitle,
            "currencyCode": priceLocale.currencyCode
        ]
        return map
    }
}





