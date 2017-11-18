//
//  DateTimeConversionTest.swift
//  DWAplatformTests
//


import XCTest
@testable import DWAplatform

class DateTimeConversionTest : XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func test_convert2RFC3339() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        let date = dateFormatter.date(from: "2017-11-06T11:00:30+00:00")
        
        // When
        let dateConverted = DateTimeConversion.init().convert2RFC3339(ts: date!)
                print(dateConverted)
        // Then
        XCTAssertTrue(dateConverted.contains("2017-11-06"))
        
    }
    
    func test_convertFromRFC3339() {
        // When
        let dateConverted = DateTimeConversion.init().convertFromRFC3339(str: "2017-11-06T11:00:30+00:00")
        
        // Then
        XCTAssertEqual("2017-11-06 11:00:30 +0000", dateConverted?.description)
    }
}
