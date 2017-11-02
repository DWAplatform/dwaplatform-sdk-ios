//
//  CardHelper.swift
//  DWApay
//
//  Created by Tiziano Cappellari on 30/10/2017.
//  Copyright © 2017 Tiziano Cappellari. All rights reserved.
//

import Foundation


class CardHelper {
    func generateAlias(cardNumber: String) -> String {
        let indexTo = cardNumber.index(cardNumber.startIndex, offsetBy: 6)
        let indexFrom = cardNumber.index(cardNumber.endIndex, offsetBy: -4)
        
        return "\(cardNumber.substring(to: indexTo))XXXXXX\(cardNumber.substring(from: indexFrom))"
    }
}

