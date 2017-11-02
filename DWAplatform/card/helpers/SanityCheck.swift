//
//  SanityCheck.swift
//  DWApay
//
//  Created by Tiziano Cappellari on 30/10/2017.
//  Copyright © 2017 Tiziano Cappellari. All rights reserved.
//

import Foundation

class SanityCheck {
    
    func check(items: [SanityItem]) -> [SanityItem] {
        return items.filter {it in
            let regex = try! NSRegularExpression(pattern: it.regExp, options: [])
        
            let matches = regex.matches(in: it.value, options: [], range: NSRange(location: 0, length: it.value.characters.count))
        
            return matches.count > 0
        }
    }
    
    func checkThrowException(items: [SanityItem]) throws {
        if (!check(items: items).isEmpty) { throw SanityCheckError.SanityCheckFailed(item: items[0]) }
    }
}

enum SanityCheckError: Error {
    case SanityCheckFailed(item: SanityItem)
}

struct SanityItem {
    var field: String
    var value: String
    var regExp: String
}

