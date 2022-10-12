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
                return _result("error")
            }
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
        case "retrieveAllItems":
            guard let params = call.arguments as? [String: String] else {
                return _result("error")
            }

            print("All items:")
            Chargebee.shared.retrieveAllItems(queryParams: params, completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(itemLst):

                        //debugPrint("items: \(itemLst.list)")
                        var items  = [String]()
                        for item in itemLst.list {

                            debugPrint("items: \(item)")

                             if let theJSONData = try? JSONSerialization.data(
                                withJSONObject: item.item.toMap(),
                                options: []) {
                                if let jsonString = String(data: theJSONData,
                                                           encoding: .ascii) {
                                    items.append(jsonString)
                                }
                            }
                        }

                         if let data = try? JSONSerialization.data(
                            withJSONObject:items,
                            options: []) {
                            if let jsonString = String(data: data,
                                                       encoding: .ascii) {
                                _result(jsonString)
                            }
                        }else {
                            debugPrint("Serialization Issue")
                            _result(FlutterError.jsonSerializationError("Serialization Issue"))
                        }
                    case let .error(error):
                        debugPrint("Error: \(error.localizedDescription)")
                        _result(FlutterError.jsonSerializationError("Serialization Issue"))
                    }
                }
            })
        case "retrieveAllPlans":
            guard let params = call.arguments as? [String: String] else {
                return _result("error")
            }
                        
            print("List All Plans")
            print(params)
            Chargebee.shared.retrieveAllPlans(queryParams: params) { result in
                switch result {
                case let .success(plansList):
                    
                     //var plans: [CBPlan] = []
                    var plans  = [CBPlan]()
                    for plan in  plansList.list {
                        plans.append(plan.plan)
                    }
                    
                    self.plans = plans
                    debugPrint("items: \(self.plans)")

                case let .error(error):
                    debugPrint("Error: \(error.localizedDescription)")
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
        ]
        return map
    }
}

extension CBPlan{
    func toMap() -> [String: Any?] {
        let map: [String: Any?] = [
            "addonApplicability": addonApplicability,
            "chargeModel": chargeModel,
            "currencyCode": currencyCode,
            "enabledInHostedPages": enabledInHostedPages,
            "enabledInPortal": enabledInPortal,
            "freeQuantity": freeQuantity,
            "giftable": giftable,
            "id": id,
            "invoiceName": invoiceName,
            "isShippable": isShippable,
            "name": name,
            "object": object,
            "period": period,
            "periodUnit": periodUnit,
            "price": price,
            "pricingModel": pricingModel,
            "resourceVersion": resourceVersion,
            "status": status,
            "taxable": taxable,
            "updatedAt": updatedAt,
            "metadata" : metadata,
        ]
        return map
    }
}

extension CBItem{
    func toMap() -> [String: Any?] {
        let map: [String: Any?] = [
            "id": id,
            "name": name,
            "description": description,
            "status": status,
            "resourceVersion": resourceVersion,
            "updatedAt": updatedAt,
            "itemFamilyId": itemFamilyId,
            "type": type,
            "isShippable": isShippable,
            "isGiftable": isGiftable,
            "enabledForCheckout": enabledForCheckout,
            "enabledInPortal": enabledInPortal,
            "metered": metered,
            "object": object,
        ]
        return map
    }
}





