//
//  CurrencyConverterComparisonTableViewCell.swift
//  FreeAgent Tech Test
//
//  Created by Alex Jacobsen on 11/03/2022.
//

import UIKit

class CurrencyConverterComparisonCell: UITableViewCell {
    
    // MARK:- Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currencyOneLabel: UILabel!
    @IBOutlet weak var currencyTwoLabel: UILabel!
    
    var model: CurrencyConverterComparisonCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CurrencyConverterComparisonCell {
    
    func updateUI() {
        guard let model = self.model else { return }
        
        dateLabel.text = model.date
        currencyOneLabel.text = model.currencyOneValue
        currencyTwoLabel.text = model.currencyTwoValue
    }
}

