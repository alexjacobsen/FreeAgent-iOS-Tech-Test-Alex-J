import Foundation

class CurrencyConverterComparisonCellViewModel {
    let currencyOneRate: CurrencyRate
    let currencyTwoRate: CurrencyRate
    
    let date: String
    
    var currencyOneValue: String {
        String(currencyOneRate.value)
    }
    
    var currencyTwoValue: String {
        String(currencyTwoRate.value)
    }
    
    init(date: String,
         currencyOneRate: CurrencyRate,
         currencyTwoRate: CurrencyRate) {
        self.date = date
        
        self.currencyOneRate = currencyOneRate
        self.currencyTwoRate = currencyTwoRate
    }
}

extension CurrencyConverterComparisonCellViewModel: Equatable {
    
    static func == (lhs: CurrencyConverterComparisonCellViewModel, rhs: CurrencyConverterComparisonCellViewModel) -> Bool {
        lhs.date == rhs.date && lhs.currencyOneValue == rhs.currencyOneValue && lhs.currencyTwoValue == rhs.currencyTwoValue
    }
    
    
}
