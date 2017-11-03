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
    private lazy var session: SessionProtocol = URLSession.shared
    
    private func getURL(path: String) -> String {
        return "https://\(hostName)\(path)"
    }
    
    private struct CardRegistration{
        let cardRegistrationId: String
        let url: String
        let preregistrationData: String
        let accessKey: String
        let tokenCard: String?
        
        init(cardRegistrationId: String, url: String, preregistrationData: String, accessKey: String, tokenCard: String? = nil) {
            self.cardRegistrationId = cardRegistrationId
            self.url = url
            self.preregistrationData = preregistrationData
            self.accessKey = accessKey
            self.tokenCard = tokenCard
        }
    }
    
    private struct CardToRegister {
        let cardNumber: String
        let expiration: String
        let cvx: String
        
        init(cardNumber: String, expiration: String, cvx: String) {
            self.cardNumber = cardNumber
            self.expiration = expiration
            self.cvx = cvx
        }
    }
    private let hostName: String
    private let sandbox: Bool
    private let sanityCheck: SanityCheck
    private let cardHelper: CardHelper
    
    init(hostName: String, sanityCheck: SanityCheck, cardHelper: CardHelper, sandbox: Bool) {
        self.hostName = hostName
        self.sanityCheck = sanityCheck
        self.cardHelper = cardHelper
        self.sandbox = sandbox
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
    public func createCreditCard(token: String,
                          cardNumber: String,
                          expiration: String,
                          cxv: String,
                          completionHandler: @escaping (Card?, Error?) -> Void) throws {
        try sanityCheck.checkThrowException(items: [
            SanityItem(field: "cardNumber", value: cardNumber, regExp: "\\d{16}"),
            SanityItem(field: "expiration", value: expiration, regExp: "\\d{4}"),
            SanityItem(field: "cxv", value: cxv, regExp: "\\d{3}")])
        
        // TODO: enqueue the following requests in a modadic for comprehension style.
        postCardRegister(token: token, alias: cardHelper.generateAlias(cardNumber: cardNumber), expiration: expiration) { optCardRegistration, optError in
            
            if let error = optError { completionHandler(nil, error); return }
            if let cardRegistration = optCardRegistration {
                self.getCardSafe(cardFrom: CardToRegister(cardNumber: cardNumber, expiration: expiration, cvx: cxv)){ (optCardSafe, optErrorCS) in
                    if let error = optErrorCS { completionHandler(nil, error); return }
                    if let cardSafe = optCardSafe {
                        self.postCardRegistrationData(card: cardSafe, cardRegistration: cardRegistration) { optRegistration, optErrorPCRD in
                            if let error = optErrorPCRD { completionHandler(nil, error); return }
                            if let registration = optRegistration {
                                self.putRegisterCard(token: token, cardRegistrationId: cardRegistration.cardRegistrationId, registration: registration) { optCard, optErrorPRC in
                                    if let error = optErrorPRC { completionHandler(nil, error); return }
                                    completionHandler(optCard, nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Create a new registration card request, to obtain data useful to send to the card tokenizer service
     *
     * @param token dwaplatform token as get from create card post request
     * @param alias card number alias
     * @param expiration card expiration
     * @param completionHandler callback containing card registration object
     */
    private func postCardRegister(token: String, alias: String, expiration: String,
    completionHandler: @escaping (CardRegistration?, Error?) -> Void) {
        
        do {
            guard let url = URL(string: getURL(path: "/rest/client/user/account/card/register"))
                else { fatalError() }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let jsonObject: NSMutableDictionary = NSMutableDictionary()
            jsonObject.setValue(alias, forKey: "alias")
            jsonObject.setValue(expiration, forKey: "expiration")
            
            let jsdata = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
            
            request.httpBody = jsdata
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addBearerAuthorizationToken(token: token)
            
            session.dataTask(with: request) { (data, response, error) in
                guard error == nil else { completionHandler(nil, error); return }
                
                guard let data = data else {
                    completionHandler(nil, WebserviceError.DataEmptyError)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(nil, WebserviceError.NoHTTPURLResponse)
                    return
                }
                
                if (httpResponse.statusCode != 200) {
                    completionHandler(nil, WebserviceError.StatusCodeNotSuccess)
                    return
                }
                
                do {
                    let reply = try JSONSerialization.jsonObject(
                        with: data,
                        options: []) as? [String:String]
                    
                    guard let cardRegistrationId = reply?["cardRegistrationId"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    guard let url = reply?["url"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    guard let preregistrationData = reply?["preregistrationData"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    guard let accessKey = reply?["accessKey"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    guard let tokenCard = reply?["tokenCard"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    completionHandler(CardRegistration(cardRegistrationId: cardRegistrationId, url: url, preregistrationData: preregistrationData, accessKey: accessKey, tokenCard: tokenCard), nil)
                    
                } catch {
                    completionHandler(nil, error)
                }
                
                
                }.resume()
            
        } catch let error {
            completionHandler(nil, error)
        }
    }
    
    /**
     * Send card registration to card tokenizer service
     *
     * @param card actual card data to tokenize
     * @param cardRegistration card registration data to authorize the tokenization
     * @param completionHandler callback containing registration key
     */
    private func postCardRegistrationData(card: CardToRegister, cardRegistration: CardRegistration, completionHandler: @escaping (String?, Error?) -> Void) {
        
        let data = "data=\(cardRegistration.preregistrationData)&accessKeyRef=\(cardRegistration.accessKey)&cardNumber=\(card.cardNumber)&cardExpirationDate=\(card.expiration)&cardCvx=\(card.cvx)"
        
        guard let url = URL(string: cardRegistration.url)
            else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data.data(using: .utf8)
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else { completionHandler(nil, error); return }
            
            guard let data = data else {
                completionHandler(nil, WebserviceError.DataEmptyError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(nil, WebserviceError.NoHTTPURLResponse)
                return
            }
            
            if (httpResponse.statusCode != 200) {
                completionHandler(nil, WebserviceError.StatusCodeNotSuccess)
                return
            }
            
            guard let responseString = String(data: data, encoding: .utf8) else {
                completionHandler(nil, WebserviceError.DataEmptyError)
                return
            }
            
            completionHandler(responseString, nil)
            
        }.resume()
    }
    
    /**
     * Complete card registration process.
     * @param token dwaplatform token as get from create card post request
     * @param cardRegistrationId univoke id obtained from card registration process
     * @param registration registration key obtained from tokenizer service
     * @param completionHandler callback containing the Card object
     */
    private func putRegisterCard(token: String, cardRegistrationId: String, registration: String, completionHandler: @escaping (Card?, Error?) -> Void) {
        
        do {
            guard let url = URL(string: getURL(path: "/rest/client/user/account/card/register/\(cardRegistrationId)"))
                else { fatalError() }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            
            let jsonObject: NSMutableDictionary = NSMutableDictionary()
            jsonObject.setValue(registration, forKey: "registration")
            
            let jsdata = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
            
            request.httpBody = jsdata
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.addBearerAuthorizationToken(token: token)
            session.dataTask(with: request) { (data, response, error) in
                guard error == nil else { completionHandler(nil, error); return }
                
                guard let data = data else {
                    completionHandler(nil, WebserviceError.DataEmptyError)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(nil, WebserviceError.NoHTTPURLResponse)
                    return
                }
                
                if (httpResponse.statusCode != 200) {
                    completionHandler(nil, WebserviceError.StatusCodeNotSuccess)
                    return
                }
                
                do {
                    let reply = try JSONSerialization.jsonObject(
                        with: data,
                        options: []) as? [String:Any]
                    
                    
                    let optId: String?
                    if let id = reply?["id"] {
                        optId = id as? String
                    } else {
                        optId = nil
                    }
                    
                    let optAlias: String?
                    if let alias = reply?["alias"] {
                        optAlias = alias as? String
                    } else {
                        optAlias = nil
                    }
                    
                    let optExpiration: String?
                    if let expiration = reply?["expiration"] {
                        optExpiration = expiration as? String
                    } else {
                        optExpiration = nil
                    }
                    
                    let optCurrency: String?
                    if let currency = reply?["currency"] {
                        optCurrency = currency as? String
                    } else {
                        optCurrency = nil
                    }
                    
                    let optDefault: Bool?
                    if let defaultValue = reply?["default"] {
                        optDefault = defaultValue as? Bool
                    } else {
                        optDefault = nil
                    }
                    
                    let optStatus: String?
                    if let status = reply?["status"] {
                        optStatus = status as? String
                    } else {
                        optStatus = nil
                    }
                    
                    let optToken: String?
                    if let token = reply?["token"] {
                        optToken = token as? String
                    } else {
                        optToken = nil
                    }
                    
                    let optCreate: String?
                    if let create = reply?["create"] {
                        optCreate = create as? String
                    } else {
                        optCreate = nil
                    }
                    
                    let optCreateDate: Date?
                    if let createDate = optCreate {
                        let dtc = DateTimeConversion()
                        optCreateDate = dtc.convertFromRFC3339(str: createDate)
                    } else {
                        optCreateDate = nil
                    }

                    let ucc = Card(id: optId, alias: optAlias, expiration: optExpiration, currency: optCurrency, defaultValue: optDefault, status: optStatus, token: optToken, create: optCreateDate)
                    
                    completionHandler(ucc, nil)
                } catch {
                    completionHandler(nil, error)
                }
                }.resume()
        } catch let error {
            completionHandler(nil, error)
        }
    }
    
    /**
     * Get Test Card data to use on sandbox environment.
     * If not in sandbox, will be returned the card dato get from cardFrom parameter.
     *
     * @param cardFrom original card data, to use only in production environment
     * @param completionHandler callback containing the card data to use for registration.
     */
    private func getCardSafe(cardFrom: CardToRegister, completionHandler: @escaping (CardToRegister?, Error?) -> Void) {
    
        if (!sandbox) {
            completionHandler(CardToRegister(cardNumber: cardFrom.cardNumber, expiration: cardFrom.expiration, cvx: cardFrom.cvx), nil)
        } else {
            
            guard let url = URL(string: getURL(path: "/rest/client/user/account/card/test"))
                else { fatalError() }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            session.dataTask(with: request) { (data, response, error) in
                guard error == nil else { completionHandler(nil, error); return }
                
                guard let data = data else {
                    completionHandler(nil, WebserviceError.DataEmptyError)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(nil, WebserviceError.NoHTTPURLResponse)
                    return
                }
                
                if (httpResponse.statusCode != 200) {
                    completionHandler(nil, WebserviceError.StatusCodeNotSuccess)
                    return
                }
                
                do {
                    let reply = try JSONSerialization.jsonObject(
                        with: data,
                        options: []) as? [String:String]
                    
                    
                    // cardNumber
                    //expiration
                    // cxv
                    guard let cardNumber = reply?["cardNumber"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    guard let expiration = reply?["expiration"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    
                    guard let cxv = reply?["cxv"] else {
                        completionHandler(nil, WebserviceError.MissingMandatoryReplyParameters)
                        return
                    }
                    completionHandler(CardToRegister(cardNumber: cardNumber, expiration: expiration, cvx: cxv), nil)
        
        
                } catch {
                    completionHandler(nil, error)
                }
                }.resume()
            
        }
    }
}


protocol SessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
    
    
}

extension URLSession: SessionProtocol {}

public enum WebserviceError : Error {
    case DataEmptyError
    case NoHTTPURLResponse
    case StatusCodeNotSuccess
    case EncodeInputParamsError
    case MissingMandatoryReplyParameters
    case NOJSONReply
    case IdempotencyError
}

