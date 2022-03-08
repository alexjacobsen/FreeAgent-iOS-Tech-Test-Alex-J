import UIKit

struct AlertConfig {
    let title: String
    let message: String
    let actions: [UIAlertAction]
}

extension AlertConfig {
    
    static func networkErrorAlertConfig (retryHandler: ((UIAlertAction) -> Void)? = nil) -> AlertConfig {
        return .init(title: "Something went wrong", message: "There was an issue fetching data would you like to retry?", actions: [.init(title: "Retry",
                                                                                                                                          style: .default,
                                                                                                                                          handler: retryHandler),
                                                                                                                                    .init(title: "Cancel",
                                                                                                                                          style: .cancel,
                                                                                                                                          handler: nil)])
    }
}
