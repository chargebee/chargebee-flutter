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
            // Added chargebee logger support for flutter ios sdk
            Chargebee.environment = "cb_flutter_ios_sdk"
            Chargebee.configure(site: args["site_name"] as! String,
                                apiKey: args["api_key"] as! String,
                                sdkKey: (args["sdk_key"] as! String)) { result in
                switch result {
                case .success(let status):
                    _result(status.details.status!)
                case .error(let error):
                    debugPrint("error : \(error)")
                    _result(FlutterError.chargebeeError(error as CBError))
                    
                }
            }
            
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
                        _result(FlutterError.jsonSerializationError("Serialization Issue"))
                    }
                case let .error(error):
                    _result(FlutterError.chargebeeError(error))
                }
            }
        case "purchaseProduct":
            guard let params = call.arguments as?  [String: String] else {
                return _result(FlutterError.noArgsError)
            }
            let productId = params["product"]
            let customer = CBCustomer(customerID: params["customerId"], firstName:params["firstName"], lastName: params["lastName"], email:params["email"])
            var dict = [String:String]()
            CBPurchase.shared.retrieveProducts(withProductID: [productId!], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        debugPrint("products: \(products)");
                        let  product: CBProduct = products.self.first!;
                        CBPurchase.shared.purchaseProduct(product: product, customer: customer) { result in
                            switch result {
                            case .success(let result):
                                if let subscriptionId = result.subscriptionId, let planId = result.planId{
                                    dict = ["status": "\(result.status)", "subscriptionId": "\(subscriptionId)", "planId": "\(planId)"]
                                }
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
                                self.onPurchaseError(error, completion: _result)
                            }
                        }
                    case let .failure(error):
                        _result(FlutterError.purchaseError(error ))
                    }
                }
            })
        case "showManageSubscriptionsSettings":
            Chargebee.shared.showManageSubscriptionsSettings()
            
        case "purchaseNonSubscriptionProduct":
            guard let params = call.arguments as?  [String: String] else {
                return _result(FlutterError.noArgsError)
            }
            let productId = params["product"]
            let productTypeString = params["product_type"]
            let productType = getProductType(productTypeString: productTypeString)
            let customer = CBCustomer(customerID: params["customerId"], firstName:params["firstName"], lastName: params["lastName"], email:params["email"])
            var dict = [String:String]()
            CBPurchase.shared.retrieveProducts(withProductID: [productId!], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        debugPrint("products: \(products)");
                        let  product: CBProduct = products.self.first!;
                        CBPurchase.shared.purchaseNonSubscriptionProduct(product: product, customer: customer, productType: productType) { result in
                            switch result {
                            case .success(let result):
                                dict = ["invoiceId": "\(result.invoiceID)", "chargeId": "\(result.chargeID)", "customerId": "\(result.customerID)"]
                            
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
                                self.onPurchaseError(error, completion: _result)
                            }
                        }
                    case let .failure(error):
                        _result(FlutterError.purchaseError(error ))
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
                        _result(FlutterError.purchaseError(error))
                    }
                }
            })
        case "retrieveProductIdentifiers":
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
                        _result(FlutterError.productIdentifierError(error.localizedDescription))
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
                    _result(FlutterError.chargebeeError(error))
                }
            }
        case "retrieveAllItems":
            let params = call.arguments as? [String: String]
            debugPrint("All items:")
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
                        _result(FlutterError.chargebeeError(error))
                    }
                }
            })
        case "retrieveAllPlans":
            let params = call.arguments as? [String: String]
            debugPrint("List All Plans")
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
                    _result(FlutterError.chargebeeError(error))
                }
            }
        case "restorePurchases":
            guard let params = call.arguments as? [String: Any?] else {
                return _result(FlutterError.noArgsError)
            }

            let includeInActiveProducts: Bool = params["includeInactivePurchases"] as? Bool ?? false

            let customer: CBCustomer = CBCustomer(
              customerID: params["customerId"] as? String,
              firstName:params["firstName"] as? String,
              lastName: params["lastName"] as? String,
              email:params["email"] as? String
            )

            CBPurchase.shared.restorePurchases(includeInActiveProducts: includeInActiveProducts, customer: customer) { result in
                switch result {
                case .success(let response):
                    var array = [String]()
                    for subscription in response {
                        if let theJSONData = try? JSONSerialization.data(
                            withJSONObject: subscription.toMap(),
                            options: []) {
                            if let jsonString = String(data: theJSONData,
                                                       encoding: .ascii) {
                                array.append(jsonString)
                            }
                        }
                    }
                    _result(array)
                case .failure(let error):
                    _result(FlutterError.restoreError(error))
                }
            }
        case "validateReceipt":
            guard let params = call.arguments as?  [String: String] else {
                return _result(FlutterError.noArgsError)
            }
            let productId = params["product"]
            let customer = CBCustomer(customerID: params["customerId"], firstName:params["firstName"], lastName: params["lastName"], email:params["email"])
    
            var dict = [String:String]()
            CBPurchase.shared.retrieveProducts(withProductID: [productId!], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        debugPrint("products: \(products)");
                        let  product: CBProduct = products.self.first!;
                        CBPurchase.shared.validateReceipt(product) { result in
                            switch result {
                            case .success(let result):
                                if let subscriptionId = result.subscriptionId, let planId = result.planId{
                                    dict = ["status": "\(result.status)", "subscriptionId": "\(subscriptionId)", "planId": "\(planId)"]
                                }
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
                                self.onPurchaseError(error, completion: _result)
                            }
                        }
                    case let .failure(error):
                        _result(FlutterError.purchaseError(error ))
                    }
                }
            })
        case "validateReceiptForNonSubscriptions":
            guard let params = call.arguments as?  [String: String] else {
                return _result(FlutterError.noArgsError)
            }
            let productId = params["product"]
            let productTypeString = params["product_type"]
            let productType = getProductType(productTypeString: productTypeString)
            var dict = [String:String]()
            CBPurchase.shared.retrieveProducts(withProductID: [productId!], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        debugPrint("products: \(products)");
                        let  product: CBProduct = products.self.first!;
                        CBPurchase.shared.validateReceiptForNonSubscriptions(product,productType) { result in
                            switch result {
                            case .success(let result):
                                dict = ["invoiceId": "\(result.invoiceID)", "chargeId": "\(result.chargeID)", "customerId": "\(result.customerID)"]
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
                                self.onPurchaseError(error, completion: _result)
                            }
                        }
                    case let .failure(error):
                        _result(FlutterError.purchaseError(error ))
                    }
                }
            })
        default:
            print("Default statement")
        }
    }
    
    private func onPurchaseError(_ error: Error, completion: @escaping FlutterResult){
        if let error = error as? CBPurchaseError {
            completion(FlutterError.purchaseError(error))
        } else if let error = error as? CBError {
            completion(FlutterError.chargebeeError(error))
        } else {
            completion(FlutterError.purchaseError(CBPurchaseError.unknown))
        }
    }
    
    private func getProductType(productTypeString: String?)-> ProductType{
        var productType: ProductType!
        if productTypeString == ProductType.Consumable.rawValue{
            productType = .Consumable
        }else if productTypeString == ProductType.NonConsumable.rawValue{
            productType = .NonConsumable
        }else {
            productType = .NonRenewingSubscription
        }
        return productType
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
            "productPrice": price.doubleValue,
            "productPriceString": price.description,
            "productTitle": localizedTitle,
            "currencyCode": priceLocale.currencyCode,
            "subscriptionPeriod": subscriptionPeriod()
        ]
        return map
    }
    func subscriptionPeriod() -> [String:Any?]  {
        let period:String = periodUnit()
        let subscriptionPeriod: [String: Any?] = [
            "periodUnit": period,
            "numberOfUnits": self.subscriptionPeriod?.numberOfUnits ?? 0
        ];
        return subscriptionPeriod
    }
    
    func periodUnit() -> String {
        switch self.subscriptionPeriod?.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        case .none, .some(_): return ""
        }
    }
}
