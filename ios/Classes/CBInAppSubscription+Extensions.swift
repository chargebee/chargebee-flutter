//
//  CBInAppSubscription+Extensions.swift
//  chargebee_flutter
//
//  Created by Amutha C on 17/05/23.
//

import Foundation
import Chargebee

extension InAppSubscription{
    func toMap() -> [String: Any?] {
        let map: [String: Any?] = [
            "subscriptionId": subscriptionID,
            "planId": planID,
            "storeStatus": storeStatus.rawValue
        ]
        return map
    }
}
