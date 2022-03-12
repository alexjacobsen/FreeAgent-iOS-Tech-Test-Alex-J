import Foundation

class CurrencyConverterOverviewCellViewModel {
    
    let title: String
    let value: String
    
    init(title: String,
         value: String) {
        self.title = title
        self.value = value
    }
}

extension CurrencyConverterOverviewCellViewModel: Equatable {
    
    static func == (lhs: CurrencyConverterOverviewCellViewModel, rhs: CurrencyConverterOverviewCellViewModel) -> Bool {
        lhs.title == rhs.title && lhs.value == rhs.value
    }
}
