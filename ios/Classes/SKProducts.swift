//
//  SKProducts.swift
//  chargebee_flutter_sdk
//
//  Created by Amutha C on 20/04/22.
//

import Foundation

struct CBProducts : Decodable {
    let productTitle: String
    let productId: String

    func toMap() -> [String: Any?] {
        return [
          "productId": productId,
          "productTitle": productTitle,
        ]
      }
}

