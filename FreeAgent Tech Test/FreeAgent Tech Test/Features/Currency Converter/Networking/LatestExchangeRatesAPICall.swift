import Foundation
import RxSwift

class LatestExchangeRatesAPICall {
    // create a method for calling api which is return a Observable
    func send<Currency: Codable>() -> Observable<Currency> {
        let apiRequest = APICall(baseURLString: "\(String.latestExchangeRatesEndpoint)",
                                    method: .GET,
                                    parameters: [.init(name: "\(String.apiKeyParameterTitle)", value: "\(String.apiKeyParameterValue)")])
        
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
}
