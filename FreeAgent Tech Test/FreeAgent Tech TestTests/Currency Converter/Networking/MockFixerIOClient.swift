import XCTest
import RxSwift
import RxTest
@testable import FreeAgent_Tech_Test

class MockFixerIOClient: FixerIOClientProtocol {
    
    // Mock exchange rates in relation to euros(EUR)
    
    let dateString: String
    
    var rates = [CurrencySymbol: Double]()
    
    public init(dateString: String = "2022-03-06",
                usdExchangeRate: Double = 2.0,
                audExchangeRate: Double = 1.5,
                cadExchangeRate: Double = 12.0,
                jpyExchangeRate: Double = 0.6,
                chfExchangeRate: Double = 19.0,
                gbpExchangeRate: Double = 3.0,
                cnyExchangeRate: Double = 4.0,
                sekExchangeRate: Double = 5.0,
                nzdExchangeRate: Double = 6.0) {
        self.dateString = dateString
        
        self.rates[.usd] = usdExchangeRate
        self.rates[.aud] = audExchangeRate
        self.rates[.cad] = cadExchangeRate
        self.rates[.jpy] = jpyExchangeRate
        self.rates[.chf] = chfExchangeRate
        self.rates[.gbp] = gbpExchangeRate
        self.rates[.cny] = cnyExchangeRate
        self.rates[.sek] = sekExchangeRate
        self.rates[.nzd] = nzdExchangeRate
    }
    
    func getLastestExchangeRates(base: CurrencySymbol, symbols: [CurrencySymbol]) -> Observable<Currency> {
        
        var currencyRates = [CurrencyRate]()
        
        for symbol in symbols {
            currencyRates.append(CurrencyRate(title: symbol, value: rates[symbol]!))
        }
        
        let currency = Currency(success: true,
                                historical: nil,
                                timestamp: 1519296206,
                                base: base,
                                date: dateString,
                                rates: currencyRates)
        
        return .just(currency)
    }
    
    func getHistoricalExchangeRates(for date: Date, base: CurrencySymbol, symbols: [CurrencySymbol]) -> Observable<Currency> {
        
        var currencyRates = [CurrencyRate]()
        
        for symbol in symbols {
            currencyRates.append(CurrencyRate(title: symbol, value: rates[symbol]!))
        }
        
        let currency = Currency(success: true,
                                historical: true,
                                timestamp: 1519296206,
                                base: base,
                                date: dateString,
                                rates: currencyRates)
        
        return .just(currency)
    }

}
