//
//  DWAplatform.swift
//  DWApay
//
//  Created by Tiziano Cappellari on 30/10/2017.
//  Copyright © 2017 Tiziano Cappellari. All rights reserved.
//

import Foundation




class DWAplatform {
    struct Configuration {
        let hostName: String
        let sandbox: Bool
        
        init(hostName: String, sandbox: Bool) {
            self.hostName = hostName
            self.sandbox = sandbox
        }
    }
    
    
    private var configuration:  Configuration? = nil
    private var cardAPIInstance: CardAPI? = nil
    
    static let sharedInstance = DWAplatform()
    
    private init() {}
    
    func initialize(config: Configuration) {
        configuration = config
    }
    
    func getCardAPI() -> CardAPI {
        guard let conf = configuration else {
            fatalError("DWAplatfrom missing configuration init")
        }
        return buildCardAPI(hostName: conf.hostName, sandbox: conf.sandbox)
    }

    private func buildCardAPI(hostName: String, sandbox: Bool) -> CardAPI {
        return CardAPI(hostName: hostName,
                       sanityCheck: SanityCheck(),
                       cardHelper: CardHelper(),
                       sandbox: sandbox)
    }
}
