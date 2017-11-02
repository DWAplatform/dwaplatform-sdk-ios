//
//  Card.swift
//  DWApay
//
//  Created by Tiziano Cappellari on 31/10/2017.
//  Copyright © 2017 Tiziano Cappellari. All rights reserved.
//

import Foundation

struct Card {
    let id: String?
    let alias: String?
    let expiration: String?
    let currency: String?
    let defaultValue: Bool?
    let status: String?
    let token: String?
    let create: Date?
    
    init(id: String?, alias: String?, expiration: String?, currency: String?, defaultValue: Bool?, status: String?, token: String?, create: Date?) {
        self.id = id
        self.alias = alias
        self.expiration = expiration
        self.currency = currency
        self.defaultValue = defaultValue
        self.status = status
        self.token = token
        self.create = create
    }
}
