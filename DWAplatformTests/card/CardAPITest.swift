//
//  CardAPITest.swift
//  DWAplatformTests
//


import XCTest
@testable import DWAplatform

class CardAPITest : XCTestCase {
    
    private var restApi: CardRestApiMock!
    private var cardHelper: CardHelperMock!
    var cardApi : CardAPI!
    
    override func setUp() {
        super.setUp()
        restApi = CardRestApiMock()
        cardHelper = CardHelperMock()
        
        cardApi = CardAPI(restApi: restApi, cardHelper: cardHelper)
    }
    
    func test_registerCardSuccess() {
        // Given
        let now = Date()
        cardHelper.generateAliasReturn = "11XXXX21"
        let cardCatched = Card(id: "456id", alias: cardHelper.generateAliasReturn, expiration: "1226", currency: "EUR", defaultValue: true, status: "WELLDONE", token: "456token", create: now)
        
        
        // When
        do{
        try cardApi.registerCard(token: "678900", cardNumber: "11987654321", expiration: "1226", cxv: "666", completionHandler: { (optcard, error) in
            // Then
            XCTAssertNotNil(optcard)
            XCTAssertNil(error)
            XCTAssertEqual("456id", optcard!.id)
            XCTAssertEqual("11XXXX21", optcard!.alias)
            XCTAssertEqual("1226", optcard!.expiration)
            XCTAssertEqual("EUR", optcard!.currency)
            XCTAssertTrue(optcard!.defaultValue!)
            XCTAssertEqual("WELLDONE", optcard!.status)
            XCTAssertEqual("456token", optcard!.token)
            XCTAssertEqual(now, optcard!.create)
            
            })
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual("11987654321", cardHelper.checkCardFormatValueCardNumber)
        XCTAssertEqual("1226", cardHelper.checkCardFormatValueExpiration)
        XCTAssertEqual("666", cardHelper.checkCardFormatValueCxv)
        
        XCTAssertEqual("678900", restApi.postCardRegisterValueToken)
        XCTAssertEqual(1, cardHelper.generatAliasCalled)
        XCTAssertEqual("11987654321", cardHelper.generateAliasValue)
        XCTAssertEqual("11XXXX21", restApi.postCardRegisterValueAlias)
        XCTAssertEqual("1226", restApi.postCardRegisterValueExpiration)
        XCTAssertEqual(1, restApi.postCardRegisterCalled)
        
        let captorPostCardRegisterHandler = restApi.postCardRegisterCompletion
        let cardRegistration = CardRestAPI.CardRegistration(cardRegistrationId: "456cardRegId", url: "myUrl", preregistrationData: "preRegData", accessKey: "456accessKey", tokenCard: "456tokenCard")
        captorPostCardRegisterHandler!(cardRegistration, nil)
        
        let cardToRegister = CardRestAPI.CardToRegister(cardNumber: "11987654321", expiration: "1226", cvx: "666")
        XCTAssertEqual(cardToRegister, restApi.getCardSafeValueCardToRegister!)
        XCTAssertEqual(1, restApi.getCardSafeCalled)
        
        let captorGetCardSafe = restApi.getCardSafeCompletion
        captorGetCardSafe!(cardToRegister, nil)
        
        XCTAssertEqual(cardToRegister, restApi.postCardRegistrationDataValueCardToRegister)
        XCTAssertEqual(cardRegistration, restApi.postCardRegistrationDataValueCardRegistration)
        XCTAssertEqual(1, restApi.postCardRegistrationDataCalled)
        
        let dataResponse = "card data tokenized"
        let captorPostCardRegistrationData = restApi.postCardRegistrationDataCompletion
        captorPostCardRegistrationData!(dataResponse, nil)
        
        XCTAssertEqual("678900", restApi.putRegisterCardVauleToken)
        XCTAssertEqual("456cardRegId", restApi.putRegisterCardValueCardRegistrationId)
        XCTAssertEqual(dataResponse, restApi.putRegisterCardValueRegistration)
        
        let captorPutRegisterCard = restApi.putRegisterCardCompletion
        captorPutRegisterCard!(cardCatched, nil)
        
    }
}
