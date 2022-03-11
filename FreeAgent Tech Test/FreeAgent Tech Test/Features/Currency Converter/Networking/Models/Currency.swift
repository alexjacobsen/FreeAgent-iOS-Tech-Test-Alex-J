
struct Currency: Codable {
    let success: Bool
    let historical: Bool? // Only will be recieved during a historical API call
    let timestamp: Int
    let base: CurrencySymbol
    let date: String
    let rates: [CurrencyRate]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rateDictionary = try container.decode([String: Double].self, forKey: .rates)
        
        var rates = [CurrencyRate]()
        
        rateDictionary.forEach { (key, value) in
            guard let title = CurrencySymbol(rawValue: key) else { return }
            rates.append(.init(title: title, value: value))
        }
        
        self.success = try container.decode(Bool.self, forKey: .success)
        self.historical = try? container.decode(Bool?.self, forKey: .historical)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.base = try container.decode(CurrencySymbol.self, forKey: .base)
        self.date = try container.decode(String.self, forKey: .date)
        self.rates = rates
    }
}

struct CurrencyRate: Codable {
    let title: CurrencySymbol
    let value: Double
}

enum CurrencySymbol: String, Codable {
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
