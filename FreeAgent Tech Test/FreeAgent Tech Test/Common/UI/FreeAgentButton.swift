import UIKit

@IBDesignable
class FreeAgentButton: UIButton {
    
    typealias TappedAction = (() -> Void)
    
    var tappedAction: TappedAction?
    
    // MARK: - Styles

    enum Style {
        // Filled blue button
        case primary
    }
    
    // MARK: - Properties
    
    var style: Style = .primary {
        didSet {
            self.styleButton()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            styleButton()
        }
    }
    
    @IBInspectable
    var isActivityIndicatorSpinning: Bool {
        get {
           return activityIndicator.isAnimating
        } set {
            if newValue {
                activityIndicator.startAnimating()
                self.accessibilityTraits.insert(.notEnabled)
                accessibilityHint = "Loading"
            } else {
                activityIndicator.stopAnimating()
                self.accessibilityTraits.remove(.notEnabled)
                accessibilityHint = nil
            }
            activityIndicator.isHidden = !newValue
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        self.isExclusiveTouch = true
        activityIndicator = UIActivityIndicatorView(frame: .zero)
        self.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        styleButton()
    }
    
    // MARK: - Configure
    
    public func configure(with title: String, action: @escaping TappedAction) {
        setTitle(title, for: .normal)
        self.tappedAction = action
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        self.tappedAction?()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = floor(bounds.size.height / 2)
        activityIndicator.layer.cornerRadius = layer.cornerRadius
        activityIndicator.frame = self.bounds
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: max(44, super.intrinsicContentSize.height))
    }
    
    // MARK: - Styling
    
    private func styleButton() {
        switch style {
        case .primary:
            backgroundColor = isEnabled ? UIColor.freeAgentBlue() : .freeAgentLightGrey()
            setTitleColor(.white, for: .normal)
            setTitleColor(.freeAgentGrey(), for: .disabled)
            activityIndicator.tintColor = .white
            activityIndicator.backgroundColor = .freeAgentBlue()
            activityIndicator.color = .white
        }
    }
    
}
