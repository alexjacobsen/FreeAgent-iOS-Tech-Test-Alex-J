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
    
    func registerReuseView(type: ReusableView.Type, in bundle: Bundle? = nil) {
        let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier)
    }
    
    func applyAutolayoutHeaderFooterView() {

        // header view
        if let headerView = tableHeaderView,
            let updatedHedaerView = resize(headerFooterView: headerView) {
            tableHeaderView = updatedHedaerView
        }

        // footer view
        if let footerView = tableFooterView,
            let updatedFooterView = resize(headerFooterView: footerView) {
            tableFooterView = updatedFooterView
        }
    }
    
    func resize(headerFooterView: UIView) -> UIView? {
        let size = headerFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        if headerFooterView.frame.size.height != size.height {
            headerFooterView.frame.size.height = size.height
            return headerFooterView
        }

        return nil
    }
}
