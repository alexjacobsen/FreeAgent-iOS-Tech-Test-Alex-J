import Foundation

class CurrencyConverterComparisonCellViewModel {
    
    let date: String
    let currencyOneValue: String
    let currencyTwoValue: String
    
    init(date: String,
         currencyOneValue: String,
         currencyTwoValue: String) {
        self.date = date
        self.currencyOneValue = currencyOneValue
        self.currencyTwoValue = currencyTwoValue
    }
}

