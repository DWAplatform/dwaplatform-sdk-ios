import Foundation

/**
 * DWAplatform Main Class.
 * Obtain all DWAplatform objects using this class.
 * Notice: before use any factory method you have to call initialize.
 *
 * Usage Example:
 *
        // Configure DWAplatform
        let dwaplatform = DWAplatform.sharedInstance
        let config = DWAplatformConfiguration(hostName: "api.sandbox.dwaplatform.com", sandbox: true)
        dwaplatform.initialize(config: config)
        
        // Get card API
        let cardAPI = dwaplatform.getCardAPI()
        
        // Register card
        // get token from POST call: .../rest/v1/:clientId/users/:userId/accounts/:accountId/cards
        let token = "XXXXXXXXYYYYZZZZKKKKWWWWWWWWWWWWTTTTTTTFFFFFFF...."
        let cardNumber = "1234567812345678"
        let expiration = "1122"
        let cxv = "123"
        
        do {
            try cardAPI.createCreditCard(token: token, cardNumber: cardNumber, expiration: expiration, cxv: cxv) {(card, e) in
                if let error = e {
                    // error handler
                    print(error)
                    return
                }
                
                guard let card = card else { fatalError() }
                print(card.id ?? "nil id")
            }
        }
        catch let error {
            // error handler
            print(error)
        }
 *
 */

public struct DWAplatformConfiguration {
    let hostName: String
    let sandbox: Bool
    
    public init(hostName: String, sandbox: Bool) {
        self.hostName = hostName
        self.sandbox = sandbox
    }
}

public class DWAplatform {
    private var configuration:  DWAplatformConfiguration? = nil
    private var cardAPIInstance: CardAPI? = nil
    
    public static let sharedInstance = DWAplatform()
    
    private init() {}
    
    
    /**
     * Initialize DWAplatform
     * @param config Configuration
     */
    public func initialize(config: DWAplatformConfiguration) {
        configuration = config
    }
    
    /**
     * Factory method to get CardAPI object
     */
    public func getCardAPI() -> CardAPI {
        guard let conf = configuration else {
            fatalError("DWAplatfrom missing configuration init")
        }
        return buildCardAPI(hostName: conf.hostName, sandbox: conf.sandbox)
    }

    private func buildCardAPI(hostName: String, sandbox: Bool) -> CardAPI {
        return CardAPI(restApi: CardRestAPI(hostName: hostName, sandbox: sandbox),
                       cardHelper: CardHelper(sanityCheck: SanityCheck()))
    }
}
