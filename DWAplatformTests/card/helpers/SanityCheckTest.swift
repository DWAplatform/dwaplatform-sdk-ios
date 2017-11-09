//
//  SanityCheckTest.swift
//  DWAplatformTests
//

import XCTest
@testable import DWAplatform

class SanityCheckTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func test_checkItems() {
        // Given
        let a = SanityItem(field: "A", value: "10", regExp: "^\\d{2}$")
        let b = SanityItem(field: "B", value: "1", regExp: "^\\d{2}$")
        let c = SanityItem(field: "C", value: "100", regExp: "^\\d{2}$")
        let d = SanityItem(field: "D", value: "100", regExp: "^\\d{3}$")
        let e = SanityItem(field: "E", value: "1000", regExp: "^\\d{3}$")
        
        let sanityCheck = SanityCheck()
        // When
        let result = sanityCheck.check(items: [a, b, c, d, e])
        
        // Then
        XCTAssertEqual(3, result.count)
        XCTAssertEqual(b, result[0])
        XCTAssertEqual(c, result[1])
        XCTAssertEqual(e, result[2])
    }
    
    func test_checkThrowException_Success() {
        // Given
        let sanityCheck = SanityCheck()
        let sanityItem = SanityItem(field: "B", value: "1", regExp: "^\\d{2}$")
        
        // When
        do {
            try sanityCheck.checkThrowException(items: [sanityItem])
            XCTFail()
        }
        
        // Then
        catch {
            XCTAssertNotNil(SanityCheckError.SanityCheckFailed(item: sanityItem))
        }
    }
    
    func test_checkThrowException_Fail() {
        // Given
        let sanityCheck = SanityCheck()
        let sanityItem = SanityItem(field: "B", value: "1", regExp: "^\\d{1}$")
        
        // When
        do {
            try sanityCheck.checkThrowException(items: [sanityItem])
        }
            
        // Then
        catch {
            XCTAssertNil(SanityCheckError.SanityCheckFailed(item: sanityItem))
        }
        
        
    }
}

