import Foundation

/**
 *Card data model
 */
public struct Card {
    public let id: String?
    public let alias: String?
    public let expiration: String?
    public let currency: String?
    public let defaultValue: Bool?
    public let status: String?
    public let token: String?
    public let create: Date?
    
    init(id: String?, alias: String?, expiration: String?, currency: String?, defaultValue: Bool?, status: String?, token: String?, create: Date?) {
        self.id = id
        self.alias = alias
        self.expiration = expiration
        self.currency = currency
        self.defaultValue = defaultValue
        self.status = status
        self.token = token
        self.create = create
    }
}
