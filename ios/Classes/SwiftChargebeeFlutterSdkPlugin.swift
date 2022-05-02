import Flutter
import UIKit
import Chargebee

public class SwiftChargebeeFlutterSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "chargebee_flutter_sdk", binaryMessenger: registrar.messenger())
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
        case "getProducts":
            
            guard let args = call.arguments as? [String: Any] else {
                return _result("error")
            }
            //print(args["product_id"])

    
            let productId = args["product_id"]
            var array = [Any?]();
            CBPurchase.shared.retrieveProducts(withProductID: productId as! [String], completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(products):
                        
                        debugPrint("products: \(products)");
                        let  product: CBProduct = products.self.first!;
                        
                        CBPurchase.shared.purchaseProduct(product: product, customerId: "") { result in
                            print(result)
                            switch result {
                            case .success(let result):
                                print(result)
                               
                            case .failure(let error):
                                print(error.localizedDescription)
                               
                            }
                        }

//                        for cbProduct in products{
//                            debugPrint("cbProduct: \(cbProduct.product)");
//
//                            let map = ["productTitle":cbProduct.product.localizedTitle,
//                                "productId": cbProduct.product.productIdentifier,
//                                //"localizedDescription": cbProduct.product.localizedDescription,
//                               // "productPrice": cbProduct.product.price,
//                                "product": cbProduct.product
//
//                            ] as [String : Any]
//                            debugPrint("map: \(map)");
//
//                            let skuProducts = CBProducts(
//                                productTitle: cbProduct.product.localizedTitle,
//                                productId: cbProduct.product.productIdentifier);
//
//                            debugPrint("skuProducts: \(skuProducts)");
//
//                            array = [skuProducts.toMap]
//                            debugPrint("array: \(array)");
//                            //let list =  [skuProducts.toMap()];
//                        }
                    
                       
                        _result(array)
                        
                    case let .failure(error):
                        debugPrint("Error: \(error.localizedDescription)")
                        _result(FlutterError.jsonSerializationError(error.localizedDescription))
                    }
                }
            })
            
            //result("iOS " + "show alert")
        default:
            print("Default statement")
        }
    }
    
    func purchaseSkProduct(customerID: String, withProduct: CBProduct) {
        
    }
}

