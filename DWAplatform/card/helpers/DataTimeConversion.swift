//
//  DataTimeConversion.swift
//  DWApay
//
//  Created by Tiziano Cappellari on 31/10/2017.
//  Copyright © 2017 Tiziano Cappellari. All rights reserved.
//

import Foundation


class DateTimeConversion {
    private let format = "yyyy-MM-dd'T'HH:mm:ssXXX"
    
    func convert2RFC3339(ts: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: ts)
    }
    
    func convertFromRFC3339(str: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: str)
    }
    
}
