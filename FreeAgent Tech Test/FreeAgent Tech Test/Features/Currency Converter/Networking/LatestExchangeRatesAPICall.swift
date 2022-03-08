import Foundation
import RxSwift

class APIRequest {
    let baseURL = URL(string: "http://data.fixer.io/api/latest?access_key=2aa762c48b2a48541c0b641039e22527")!
    var method = RequestType.GET
    var parameters = [String: String]()
    
    func request(with baseURL: URL) -> URLRequest {
           var request = URLRequest(url: baseURL)
            request.httpMethod = method.rawValue
            return request
        }
}

class APICalling {
    // create a method for calling api which is return a Observable
    func send<Currency: Codable>(apiRequest: APIRequest) -> Observable<Currency> {
        return Observable<Currency>.create { observer in
            let request = apiRequest.request(with: apiRequest.baseURL)
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
