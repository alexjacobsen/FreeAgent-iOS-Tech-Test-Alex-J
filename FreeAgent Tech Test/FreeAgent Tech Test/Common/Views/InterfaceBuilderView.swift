import UIKit

@IBDesignable
open class InterfaceBuilderView: UIView {

    // MARK: - Properties
    var contentView: UIView?

    // MARK: - Overridden
    override open func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }

    // MARK: - Initialisers
    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.xibSetup()
    }
}

// MARK: - Private Implementation Details
private extension InterfaceBuilderView {

    func xibSetup() {

        if subviews.isEmpty {
            let bundle = Bundle(for: type(of: self))

            guard let view = loadViewFromNib(bundle: bundle) else { return }

            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
            contentView = view
        }
    }

    func loadViewFromNib(bundle: Bundle) -> UIView? {

        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

