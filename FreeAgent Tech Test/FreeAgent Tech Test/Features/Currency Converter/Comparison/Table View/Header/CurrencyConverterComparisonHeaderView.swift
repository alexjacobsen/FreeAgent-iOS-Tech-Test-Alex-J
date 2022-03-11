import UIKit

final class CurrencyConverterComparisonHeaderView: InterfaceBuilderView {
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var currencyOneTitleLabel: UILabel!
    @IBOutlet weak var currencyTwoTitleLabel: UILabel!
    
    var model: CurrencyConverterComparisonHeaderViewModel? {
        didSet {
            updateUI()
        }
    }

}

extension CurrencyConverterComparisonHeaderView {
    
    func updateUI() {
        guard let model = self.model else { return }
        
        dateTitleLabel.text = model.dateTitle
        currencyOneTitleLabel.text = model.currencyOneTitle
        currencyTwoTitleLabel.text = model.currencyTwoTitle
    }
}

extension CurrencyConverterComparisonHeaderView: ReusableView {}
