import Foundation

extension String {
    
    static let fixerAPIBaseEndpoint = "http://data.fixer.io/api/"
    static let latestExchangeRatesEndpoint = "\(fixerAPIBaseEndpoint)/latest"
    static let historicalRatesEndPoint = "https://data.fixer.io/api/"
    
    static func historicalRatesEndPoint(for date: Date) -> String {
        return "\(fixerAPIBaseEndpoint)\(date.yearLongMonthShortDayShort)"
    }
}
