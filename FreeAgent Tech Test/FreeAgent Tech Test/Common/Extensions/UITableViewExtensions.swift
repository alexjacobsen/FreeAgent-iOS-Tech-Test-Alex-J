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
    
    /// Dequeue a generic reusable cell
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable cell of type: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    func register(types: [ReusableView.Type], in bundle: Bundle? = nil) {
        types.forEach {
            let nib = UINib(nibName: $0.reuseIdentifier, bundle: bundle)
            register(nib, forCellReuseIdentifier: $0.reuseIdentifier)
        }
    }
    
    func registerReuseView(type: ReusableView.Type, in bundle: Bundle? = nil) {
        let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier)
    }
    
    // Dequeue a generic header
    func dequeueHeader<T: UITableViewHeaderFooterView>() -> T {
        let nibName = String(describing: T.self)
        let header = dequeueReusableHeaderFooterView(withIdentifier: nibName) as! T
        return header
    }
    
    func dequeueReuseView<T: UITableViewHeaderFooterView>() -> T {
        let nibName = String(describing: T.self)
        let header = dequeueReusableHeaderFooterView(withIdentifier: nibName) as! T
        return header
    }
}
