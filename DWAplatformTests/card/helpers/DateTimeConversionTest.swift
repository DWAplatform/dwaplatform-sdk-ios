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
        var component = DateComponents()
        component.day = 07
        component.month = 05
        component.year = 2017
        component.timeZone = TimeZone(abbreviation: "CET")
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "CET")!

        var date = cal.date(from: component)!
        let calendar = Calendar.current
        date = calendar.date(bySettingHour: 11, minute: 00, second: 30, of: date)!
        // When
        let dateConverted = DateTimeConversion.init().convert2RFC3339(ts: date)
                print(dateConverted)
        // Then
        XCTAssertTrue(dateConverted.contains("2017-05-07"))
        
    }
    
    func test_convertFromRFC3339() {
        // When
        let dateConverted = DateTimeConversion.init().convertFromRFC3339(str: "2017-11-06T11:00:30+00:00")
        
        // Then
        XCTAssertEqual("2017-11-06 11:00:30 +0000", dateConverted?.description)
    }
}
