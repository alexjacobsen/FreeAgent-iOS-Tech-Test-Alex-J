import UIKit

public protocol ReusableView {
    static var reuseIdentifier: String { get }
}

public extension ReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {}

extension UITableViewHeaderFooterView: ReusableView {}

public extension UITableView {
    
    func register(types: [ReusableView.Type], in bundle: Bundle? = nil) {
        types.forEach {
            let nib = UINib(nibName: $0.reuseIdentifier, bundle: bundle)
            register(nib, forCellReuseIdentifier: $0.reuseIdentifier)
        }
    }
}
