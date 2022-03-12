import Foundation
import RxSwift

protocol FixerIOClientProtocol {
    func getLastestExchangeRates(base: CurrencySymbol, symbols: [CurrencySymbol]) -> Observable<Currency>
    func getHistoricalExchangeRates(for date: Date, base: CurrencySymbol, symbols: [CurrencySymbol]) -> Observable<Currency>
}

public class FixerIOClient: FixerIOClientProtocol {
    
    
    /// This method makes a GET call to retrieve the latest exchange rates for a provided base currency
    /// - Parameters:
    ///   - base: The base currency
    ///   - symbols: The currencies being compared againsts the base
    /// - Returns: A Currency model
    func getLastestExchangeRates(base: CurrencySymbol = .eur,
                                                    symbols: [CurrencySymbol]) -> Observable<Currency> {
        
        let apiKeyParameter = URLQueryItem(name: String.apiKeyParameterTitle, value: String.apiKeyParameterValue)
        let baseCurrencyParameter = URLQueryItem(name: String.apiKeyBaseCurrencyParameterTitle, value: base.rawValue)
        let symbolsParameter = URLQueryItem(name: String.currencySymbolsParameterTitle, value: (symbols.map { $0.rawValue }).joined(separator: ","))
        let apiRequest = APICall(baseURLString: "\(String.latestExchangeRatesEndpoint)",
                                 method: .GET,
                                 parameters: [apiKeyParameter,
                                              baseCurrencyParameter,
                                              symbolsParameter])
        
        return Observable<Currency>.create { observer in
            let request = apiRequest.request()
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let model: Currency = try JSONDecoder().decode(Currency.self, from: data ?? Data())
                    print(model)
                    observer.onNext(model)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    /// This method makes a GET call to retrieve histrocial exchange rates for selected currencies compared against a base currency for a particular date.
    /// - Parameters:
    ///   - date: The date of the rates to be retrieved
    ///   - base: The base currency
    ///   - symbols: The currencies being compared againsts the base
    /// - Returns: A Currency model
    func getHistoricalExchangeRates(for date: Date,
                                                       base: CurrencySymbol,
                                                       symbols: [CurrencySymbol]) -> Observable<Currency> {
        
        let apiKeyParameter = URLQueryItem(name: String.apiKeyParameterTitle, value: String.apiKeyParameterValue)
        let baseCurrencyParameter = URLQueryItem(name: String.apiKeyBaseCurrencyParameterTitle, value: base.rawValue)
        let symbolsParameter = URLQueryItem(name: String.currencySymbolsParameterTitle, value: (symbols.map { $0.rawValue }).joined(separator: ","))
        
        let apiRequest = APICall(baseURLString: "\(String.historicalRatesEndPoint(for: date))",
                                 method: .GET,
                                 parameters: [apiKeyParameter,
                                              baseCurrencyParameter,
                                              symbolsParameter])
        
        return Observable<Currency>.create { observer in
            let request = apiRequest.request()
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let model: Currency = try JSONDecoder().decode(Currency.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
