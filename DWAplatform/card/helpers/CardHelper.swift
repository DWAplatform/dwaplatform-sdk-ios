import Foundation

/**
 * Card helper class.
 * Check card data validity and create card number alias.
 */
class CardHelper {
    func generateAlias(cardNumber: String) -> String {
        let indexTo = cardNumber.index(cardNumber.startIndex, offsetBy: 6)
        let indexFrom = cardNumber.index(cardNumber.endIndex, offsetBy: -4)
        
        return "\(cardNumber.substring(to: indexTo))XXXXXX\(cardNumber.substring(from: indexFrom))"
    }
}

