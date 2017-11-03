import Foundation

/**
 * Date time conversion from and to RFC3339 standard
 */
public class DateTimeConversion {
    private let format = "yyyy-MM-dd'T'HH:mm:ssXXX"
    
    public func convert2RFC3339(ts: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: ts)
    }
    
    public func convertFromRFC3339(str: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: str)
    }
    
}
