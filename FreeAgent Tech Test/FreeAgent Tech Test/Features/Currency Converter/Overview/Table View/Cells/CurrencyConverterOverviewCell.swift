import UIKit

class CurrencyConverterOverviewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    var model: CurrencyConverterOverviewCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .freeAgentBlue()
        self.selectedBackgroundView = backgroundView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        titleLabel.textColor = selected ? .white : .freeAgentBlue()
        valueLabel.textColor = selected ? .white : .freeAgentBlue()
    }
    
}

extension CurrencyConverterOverviewCell {
    
    func updateUI() {
        guard let model = self.model else { return }
        
        titleLabel.text = model.title
        valueLabel.text = model.value
    }
}

