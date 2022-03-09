import Foundation

class APICall {
    
    let baseURLString: String
    var method:RequestType
    var parameters: [URLQueryItem]?
    
    init(baseURLString: String,
         method: RequestType,
         parameters: [URLQueryItem]? = nil) {
        self.baseURLString = baseURLString
        self.method = method
        self.parameters = parameters
    }
    
    func request() -> URLRequest {
        var components = URLComponents(string: baseURLString)
        components?.queryItems = parameters
        let url = components?.url
        var request = URLRequest(url: url!)
            request.httpMethod = method.rawValue
            return request
        }
}

extension String {
    static let apiKeyParameterTitle = "access_key"
    static let apiKeyParameterValue = "2aa762c48b2a48541c0b641039e22527"
}
