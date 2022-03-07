import UIKit

class CurrencyConverterValueCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    var model: CurrencyConverterValueCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

extension CurrencyConverterValueCell {
    
    func updateUI() {
        guard let model = self.model else { return }
        titleLabel.text = model.title
        valueLabel.text = model.value
    }
}

