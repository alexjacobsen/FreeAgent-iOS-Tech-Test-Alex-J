
struct Currency: Codable {
    let success: Bool
    let historical: Bool? // Only will be recieved during a historical API call
    let timestamp: Int
    let base: CurrencyAbbreviation
    let date: String
    let rates: [CurrencyRate]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rateDictionary = try container.decode([String: Double].self, forKey: .rates)
        
        var rates = [CurrencyRate]()
        
        rateDictionary.forEach { (key, value) in
            guard let title = CurrencyAbbreviation(rawValue: key) else { return }
            rates.append(.init(title: title, value: value))
        }
        
        self.success = try container.decode(Bool.self, forKey: .success)
        self.historical = try? container.decode(Bool?.self, forKey: .historical)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.base = try container.decode(CurrencyAbbreviation.self, forKey: .base)
        self.date = try container.decode(String.self, forKey: .date)
        self.rates = rates
    }
}

struct CurrencyRate: Codable {
    let title: CurrencyAbbreviation
    let value: Double
}

enum CurrencyAbbreviation: String, Codable {
    case usd = "USD"
    case eur = "EUR"
    case jpy = "JPY"
    case gbp = "GBP"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case sek = "SEK"
    case nzd = "NZD"
}
