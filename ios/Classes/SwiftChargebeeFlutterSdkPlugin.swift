import Flutter
import UIKit
import Chargebee
import StoreKit

public class SwiftChargebeeFlutterSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "chargebee_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftChargebeeFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result _result: @escaping FlutterResult) {
        
        switch call.method {
        case "authentication":
            guard let args = call.arguments as? [String: Any] else {
                return _result("error")
            }
            // Added chargebee logger support for flutter ios sdk
            Chargebee.environment = "cb_flutter_ios_sdk"
            Chargebee.configure(site: args["site_name"] as! String,
                                apiKey: args["api_key"] as! String,
                                sdkKey: (args["sdk_key"] as! String))
        case "retrieveSubscriptions":
            guard let args = call.arguments as? [String: String] else {
                return _result("error")
            }
            
            Chargebee.shared.retrieveSubscriptions(queryParams: args) { result in
                switch result {
                case let .success(list):
                    debugPrint("Subscription Status Fetched: \(list)")
                    if let data = try? JSONSerialization.data(
                        withJSONObject:list.compactMap { $0.dict },
                                    options: []) {
                                    if let jsonString = String(data: data,
                                                               encoding: .utf8) {
                                        _result(jsonString)
                                    }
                                }else {
                                    debugPrint("Serialization Issue");
                                }
                    
                case let .error(error):
                    debugPrint("Error Fetched: \(error)")
                    _result(FlutterError.jsonSerializationError(error.localizedDescription))
                }
            }
        case "purchaseProduct":
            guard let params = call.arguments as?  [String: String] else {
                return _result("error")
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
                                let dict = ["status": "\(result.status)", "id": "\(result.subscriptionId)"]
                                if let data = try? JSONSerialization.data(
                                    withJSONObject:dict,
                                    options: []) {
                                    if let jsonString = String(data: data,
                                                               encoding: .ascii) {
                                        _result(jsonString)
                                    }
                                }else {
                                    debugPrint("Serialization Issue");
                                }
                            case .failure(let error):
                                _result(FlutterError.jsonSerializationError(error.localizedDescription))
                            }
                        }
                    case let .failure(error):
                        debugPrint("Error: \(error.localizedDescription)")
                        _result(FlutterError.jsonSerializationError(error.localizedDescription))
                    }
                }
            })
            
        case "getProducts":
            guard let args = call.arguments as? [String: Any] else {
                return _result("error")
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
                        debugPrint("Error: \(error.localizedDescription)")
                        _result(FlutterError.jsonSerializationError(error.localizedDescription))
                    }
                }
            })
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
        ]
        return map
    }
}





