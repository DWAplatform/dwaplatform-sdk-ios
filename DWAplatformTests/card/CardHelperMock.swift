//
//  CardHelperMock.swift
//  DWAplatformTests
//
import XCTest
@testable import DWAplatform

class CardHelperMock : CardHelper {
    
    init() {
        super.init(sanityCheck: SanityCheck())
    }
    
    var generatAliasCalled = 0
    var generateAliasValue : String? = nil
    var generateAliasReturn : String = ""
    override func generateAlias(cardNumber: String) -> String {
        generatAliasCalled += 1
        generateAliasValue = cardNumber
        return generateAliasReturn
    }
    
    var checkCardNumberFormatValue : String? = nil
    var checkCardNumberFormatThrows : SanityCheckError? = nil
    override func checkCardNumberFormat(cardNumber: String) throws {
        checkCardCXVFormatValue = cardNumber
        if let e = checkCardNumberFormatThrows {
            throw e
        }
    }
    
    var checkCardExpirationValue : String? = nil
    var checkCardExpirationFormat : SanityCheckError? = nil
    override func checkCardExpirationFormat(expiration: String) throws {
        checkCardExpirationValue = expiration
        if let e = checkCardExpirationFormat {
            throw e
        }
    }
    
    var checkCardCXVFormatValue : String? = nil
    var checkCardCXVFormat : SanityCheckError? = nil
    override func checkCardCXVFormat(cxv: String) throws {
        checkCardExpirationValue = cxv
        if let e = checkCardCXVFormat {
            throw e
        }
    }
    
    var checkCardFormat : SanityCheckError? = nil
    var checkCardFormatValueCardNumber : String? = nil
    var checkCardFormatValueExpiration : String? = nil
    var checkCardFormatValueCxv : String? = nil
    override func checkCardFormat(cardNumber: String, expiration: String, cxv: String) throws {
        checkCardFormatValueExpiration = expiration
        checkCardFormatValueCxv = cxv
        checkCardFormatValueCardNumber = cardNumber
        if let e = checkCardCXVFormat {
            throw e
        }
    }
}
