import Foundation

/**
 * DWAplatform rest API communication class.
 * Please do not use directly, use CardAPI facade instead.
 */
class CardRestAPI {
    public lazy var session: SessionProtocol = URLSession.shared
    
    private let hostName: String
    private let sandbox: Bool
    
    private func getURL(path: String) -> String {
        if (hostName.starts(with: "http://") || hostName.starts(with: "https://")) {
            return "\(hostName)\(path)"
        }
        else {
            return "https://\(hostName)\(path)"
        }
    }
    
    init(hostName: String, sandbox: Bool) {
        self.hostName = hostName
        self.sandbox = sandbox
    }
    
    struct CardRegistration{
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
    
    struct CardToRegister {
        let cardNumber: String
        let expiration: String
        let cvx: String
        
        init(cardNumber: String, expiration: String, cvx: String) {
            self.cardNumber = cardNumber
            self.expiration = expiration
            self.cvx = cvx
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
    func postCardRegister(token: String, alias: String, expiration: String,
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
    func postCardRegistrationData(card: CardToRegister, cardRegistration: CardRegistration, completionHandler: @escaping (String?, Error?) -> Void) {
        
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
    func putRegisterCard(token: String, cardRegistrationId: String, registration: String, completionHandler: @escaping (Card?, Error?) -> Void) {
        
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
    func getCardSafe(cardFrom: CardToRegister, completionHandler: @escaping (CardToRegister?, Error?) -> Void) {
        
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

enum WebserviceError : Error {
    case DataEmptyError
    case NoHTTPURLResponse
    case StatusCodeNotSuccess
    case EncodeInputParamsError
    case MissingMandatoryReplyParameters
    case NOJSONReply
    case IdempotencyError
}

extension CardRestAPI.CardRegistration : Equatable {}
func ==(lhs : CardRestAPI.CardRegistration, rhs : CardRestAPI.CardRegistration) -> Bool {
    return lhs.accessKey == rhs.accessKey &&
        lhs.cardRegistrationId == rhs.cardRegistrationId &&
        lhs.preregistrationData == rhs.preregistrationData &&
        lhs.url == rhs.url &&
        lhs.tokenCard == rhs.tokenCard
}

extension CardRestAPI.CardToRegister : Equatable {}
func ==(lhs : CardRestAPI.CardToRegister, rhs : CardRestAPI.CardToRegister) -> Bool {
    return lhs.cardNumber == rhs.cardNumber &&
        lhs.cvx == rhs.cvx &&
        lhs.expiration == rhs.expiration
}
