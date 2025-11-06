import Foundation

public extension Double {
    var currencyString: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
