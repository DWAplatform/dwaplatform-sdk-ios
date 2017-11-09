//
//  CardHelperTest.swift
//  DWAplatformTests
//

import XCTest
@testable import DWAplatform

class CardHelperTest : XCTestCase {
    
    var cardHelper : CardHelper!
    
    override func setUp() {
        cardHelper = CardHelper(sanityCheck: SanityCheck())
    }
    
    func test_generateAlias(){
        // Given
        let cardNumb = "1234567890987698"
        
        // When
        let alias = cardHelper.generateAlias(cardNumber: cardNumb)
        
        // Then
        XCTAssertNotEqual("12345678909876", alias)
        XCTAssertEqual(16, alias.count)
        XCTAssertTrue(alias.contains("XXXXXX"))
    }
    
    func test_checkCardNumberFormatCorrect() {
        // Given
        let cardNumb = "1234567890987654"
        
        // When
        do{
            try cardHelper.checkCardNumberFormat(cardNumber: cardNumb)
        } catch {
            XCTFail()
        }
    }
    
    func test_checkCardNumberFormatNotCorrect() {
        // When
        do{
            try cardHelper.checkCardNumberFormat(cardNumber: "1234567890")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardNumberFormat(cardNumber: "123456789avc098")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardNumberFormat(cardNumber: "123456789098-&")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_checkCardExpirationFormatCorrect() {
        // When
        do{
            try cardHelper.checkCardExpirationFormat(expiration: "1234")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_checkCardExpirationFormatNotCorrect() {
        // When
        do{
            try cardHelper.checkCardExpirationFormat(expiration: "12/20")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardExpirationFormat(expiration: "12a3")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardExpirationFormat(expiration: "123")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_checkCardCXVFormatCorrect() {
        // When
        do{
            try cardHelper.checkCardCXVFormat(cxv: "123")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_checkCardCXVFormatNotCorrect() {
        // When
        do{
            try cardHelper.checkCardCXVFormat(cxv: "1233")
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardCXVFormat(cxv: "12a3")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardCXVFormat(cxv: "12")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardCXVFormat(cxv: "1 2")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardCXVFormat(cxv: "1a2")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_checkCardFormatCorrect() {
        // When
        do{
            try cardHelper.checkCardFormat(cardNumber: "1234567890987654", expiration: "2109", cxv: "876")
            try cardHelper.checkCardFormat(cardNumber: "1234567890987654", expiration: "9988", cxv: "124")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_checkCardFormatNotCorrect() {
        // When
        do{
            try cardHelper.checkCardFormat(cardNumber: "123456789098", expiration: "2189", cxv: "876")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardFormat(cardNumber: "1234567890987654", expiration: "998", cxv: "124")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardFormat(cardNumber: "1234567890987654", expiration: "9985", cxv: "1a4")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
        do{
            try cardHelper.checkCardFormat(cardNumber: "1234wsfcp0987654", expiration: "9982", cxv: "124")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
