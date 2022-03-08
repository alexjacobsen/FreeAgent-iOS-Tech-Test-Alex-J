import UIKit

/**
 The Coordinator pattern should be used to navigate throughout the app.
 It decouples view controllers, making them more reusable.
 */
public protocol Coordinator {

    /// Start method of coordinator should launch or present the first view controller
    func start()

    /// Clear any child controllers/coordinators and pop navigation controller back to root
    func reset()
}

public extension Coordinator {

    func reset() { }

    /// Return class name E.g. converterCoordinator
    var className: String {
        return String(describing: type(of: self))
    }
}
