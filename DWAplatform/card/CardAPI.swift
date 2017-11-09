import Foundation

extension URLRequest {
    mutating func addBearerAuthorizationToken(token: String) {
        self.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

/**
 * Main class for API communication with DWAplatform to handle Cards.
 * Please use DWAplatform to get Card API instance; do not create directly
 *
 */
public class CardAPI {
    private let restApi: CardRestAPI
    
    private let cardHelper: CardHelper
    
    init(restApi: CardRestAPI, cardHelper: CardHelper) {
        self.restApi = restApi
        self.cardHelper = cardHelper
    }
    
    /**
     *  Register a Card. Use this method to register a user card and PLEASE DO NOT save card information on your own client or server side.
     *
     *  @param token token returned from DWAplatform to the create card request.
     *  @param cardNumber 16 digits user card number, without spaces or dashes
     *  @param expiration card expiration date in MMYY format
     *  @param cxv  3 digit cxv card number
     *  @param completionHandler callback called after the server communication is done and containing a Card object or an Exception in case of error.
     */
    public func registerCard(token: String,
                          cardNumber: String,
                          expiration: String,
                          cxv: String,
                          completionHandler: @escaping (Card?, Error?) -> Void) throws {
        
//        cardHelper.checkCardFormat(cardNumber, expiration, cxv)
        
        try cardHelper.checkCardFormat(cardNumber: cardNumber, expiration: expiration, cxv: cxv)
        
        // TODO: enqueue the following requests in a modadic for comprehension style.
        restApi.postCardRegister(token: token, alias: cardHelper.generateAlias(cardNumber: cardNumber), expiration: expiration) { optCardRegistration, optError in
            
            if let error = optError { completionHandler(nil, error); return }
            if let cardRegistration = optCardRegistration {
                self.restApi.getCardSafe(cardFrom: CardRestAPI.CardToRegister(cardNumber: cardNumber, expiration: expiration, cvx: cxv)){ (optCardSafe, optErrorCS) in
                    if let error = optErrorCS { completionHandler(nil, error); return }
                    if let cardSafe = optCardSafe {
                        self.restApi.postCardRegistrationData(card: cardSafe, cardRegistration: cardRegistration) { optRegistration, optErrorPCRD in
                            if let error = optErrorPCRD { completionHandler(nil, error); return }
                            if let registration = optRegistration {
                                self.restApi.putRegisterCard(token: token, cardRegistrationId: cardRegistration.cardRegistrationId, registration: registration) { optCard, optErrorPRC in
                                    if let error = optErrorPRC { completionHandler(nil, error); return }
                                    completionHandler(optCard, nil)
                                } // end putRegisterCard
                            }
                        } // end postCardRegistrationData
                    }
                } // end getCardSafe
            }
        } // end postCardRegister
    }
}

