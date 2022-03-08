import Foundation

import UIKit

protocol Storyboardable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String? { get }
}

extension Storyboardable {
    static var storyboardBundle: Bundle? { return nil }
    
    static func create() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        
        if let storyboardIdentifier = storyboardIdentifier {
            return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
        } else {
            return storyboard.instantiateInitialViewController() as! Self
        }
    }
}
