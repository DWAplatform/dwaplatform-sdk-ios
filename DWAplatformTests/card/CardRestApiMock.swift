//
//  CardRestApiMock.swift
//  DWAplatformTests
//

import XCTest
@testable import DWAplatform

class CardRestApiMock : CardRestAPI {
    
    init() {
        super.init(hostName: "hostName", sandbox: true)
    }
    
    var postCardRegistrationDataCalled = 0
    var postCardRegistrationDataValueCardToRegister : CardRestAPI.CardToRegister? = nil
    var postCardRegistrationDataValueCardRegistration : CardRestAPI.CardRegistration? = nil
    var postCardRegistrationDataCompletion: ((String?, Error?) -> Void)?
    override func postCardRegistrationData(card: CardRestAPI.CardToRegister, cardRegistration: CardRestAPI.CardRegistration, completionHandler: @escaping (String?, Error?) -> Void) {
        postCardRegistrationDataCalled += 1
        postCardRegistrationDataValueCardToRegister = card
        postCardRegistrationDataValueCardRegistration = cardRegistration
        postCardRegistrationDataCompletion = completionHandler
    }
    
    var postCardRegisterCalled = 0
    var postCardRegisterValueToken : String? = nil
    var postCardRegisterValueAlias : String? = nil
    var postCardRegisterValueExpiration : String? = nil
    var postCardRegisterCompletion : ((CardRestAPI.CardRegistration?, Error?) -> Void)?
    override func postCardRegister(token: String, alias: String, expiration: String, completionHandler: @escaping (CardRestAPI.CardRegistration?, Error?) -> Void) {
        postCardRegisterCalled += 1
        postCardRegisterValueToken = token
        postCardRegisterValueAlias = alias
        postCardRegisterValueExpiration = expiration
        postCardRegisterCompletion = completionHandler
    }
    
    var getCardSafeCalled = 0
    var getCardSafeValueCardToRegister : CardRestAPI.CardToRegister? = nil
    var getCardSafeCompletion : ((CardRestAPI.CardToRegister?, Error?) -> Void)?
    override func getCardSafe(cardFrom: CardRestAPI.CardToRegister, completionHandler: @escaping (CardRestAPI.CardToRegister?, Error?) -> Void) {
        getCardSafeCalled += 1
        getCardSafeValueCardToRegister = cardFrom
        getCardSafeCompletion = completionHandler
    }
    
    var putRegisterCardCalled = 0
    var putRegisterCardVauleToken : String? = nil
    var putRegisterCardValueCardRegistrationId : String? = nil
    var putRegisterCardValueRegistration : String? = nil
    var putRegisterCardCompletion : ((Card?, Error?) -> Void)?
    override func putRegisterCard(token: String, cardRegistrationId: String, registration: String, completionHandler: @escaping (Card?, Error?) -> Void) {
        putRegisterCardCalled += 1
        putRegisterCardVauleToken = token
        putRegisterCardValueCardRegistrationId = cardRegistrationId
        putRegisterCardValueRegistration = registration
        putRegisterCardCompletion = completionHandler
    }
}
