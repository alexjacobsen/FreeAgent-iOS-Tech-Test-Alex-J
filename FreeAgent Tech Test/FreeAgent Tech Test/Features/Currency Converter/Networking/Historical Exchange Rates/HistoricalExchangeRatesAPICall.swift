import Foundation
import RxSwift

class HistoricalExchangeRatesAPICall {
    
    // create a method for calling api which is return a Observable
    func send<Currency: Codable>(for date: Date,
                                 base: CurrencyAbbreviation,
                                 symbols: [CurrencyAbbreviation]) -> Observable<Currency> {
        
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
