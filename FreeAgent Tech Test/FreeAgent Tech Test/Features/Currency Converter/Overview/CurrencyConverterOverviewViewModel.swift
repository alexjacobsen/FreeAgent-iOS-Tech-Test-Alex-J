import RxSwift
import RxCocoa
import UIKit

protocol CurrencyConverterOverviewViewModelProtocol {
    var title: String { get }
    var initialEurosValue: String { get }
    var items: Driver<[CurrencyConverterValueCellViewModel]> { get }
    var unselectRowAt: Observable<Int> { get }
    var enableCompareButton: Observable<Bool> { get }
    
    func isValidInput(currentText: String?, inputText: String, range: NSRange) -> Bool
}

enum TableItem {
    case currencyValueCell(_ viewModel: CurrencyConverterValueCellViewModel)
}

// TODO: move to its own file
struct Currencies {
    let currencies: [Currency]
}

struct Currency: Codable {
    let success: Bool
    let timestamp: Int
    let base: CurrencyAbbreviation
    let date: Date
    let rates: [CurrencyRate]
}

struct CurrencyRate: Codable {
    let title: CurrencyAbbreviation
    let value: Double
}

enum CurrencyAbbreviation: String, Codable {
    case usd = "USD"
    case eur = "EUR"
    case jpy = "JPY"
    case gbp = "GBP"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case sek = "SEK"
    case nzd = "NZD"
}

struct CurrencyConverterOverviewViewModel {
    
    private let disposeBag = DisposeBag()
    private let output: Output
        
    init(input: UIInput,
         currencies: Currencies,
         navigateToComparison: @escaping () -> Void) {
        
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterValueCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterValueCellViewModel]> = cellViewModelsSource.switchLatest()
        let eurosValue = PublishSubject<Double>()
        let unselectRowsSource = PublishSubject<Int>()
        let enableCompareSource = PublishSubject<Bool>()
        
        var selectedCellIndexes = [Int]() {
            didSet {
                if selectedCellIndexes.count == 2 {
                    // When there are 2 selected values enable the compare button
                    enableCompareSource.onNext(true)
                } else {
                    enableCompareSource.onNext(false)
                }
            }
        }
        var cellViewModels = [CurrencyConverterValueCellViewModel]()
            
        eurosValue.onNext(100.0)
        
        /// Subcribing to changes of the euros value allows us to build the datasource in the fly with the changes typed into the textfield
        eurosValue.subscribe(onNext: { eurosValue in
            guard let euroCurrency = currencies.currencies.first(where: { $0.base == .eur }) else { fatalError("Euros not available in response") }
                        
            cellViewModels = euroCurrency.rates.map { (rate) -> CurrencyConverterValueCellViewModel in
                CurrencyConverterValueCellViewModel(title: rate.title.rawValue, value: String(rate.value * eurosValue))
            }
                        
            cellViewModelsSource.onNext(.just(cellViewModels))
        }).disposed(by: disposeBag)
        
        let items = cellViewModelsObservable.share(replay: 1)
        
        /// This code handles keeping track of selected rows
        input.itemSelected.subscribe(onNext: {
            let selectedRow = $0.row
            
            if selectedCellIndexes.count == 2 {
                if let oldestSelectedRow = selectedCellIndexes.first {
                    unselectRowsSource.onNext(oldestSelectedRow)
                }
                selectedCellIndexes.removeFirst()
            }
            selectedCellIndexes.append(selectedRow)
        })
        .disposed(by: disposeBag)
        
        /// This code handles keeping track of deselected rows
        input.itemDeselected.subscribe(onNext: {
            let selectedRow = $0.row
            
            // Remove the row if it is already in the array
            if let selectedRowIndex = selectedCellIndexes.firstIndex(of: selectedRow) {
                selectedCellIndexes.remove(at: selectedRowIndex)
            } else {
                fatalError("The selected row should already be inside the array as its being deselected")
            }
        })
        .disposed(by: disposeBag)
                
        /// This code handles updating the new euros value
        input.eurosValueEntered.subscribe(onNext: { eurosString in
            if let eurosString = eurosString,
               let euros = Double(eurosString) {
                eurosValue.onNext(euros)
            } else {
                cellViewModelsSource.onNext(.just([]))
                enableCompareSource.onNext(false)
                
            }
        }).disposed(by: disposeBag)
        
        output = Output(title: "Currency Converter",
                        initialEurosValue: "100.70",
                        items: items.asDriverOrAssertionFailure(),
                        unselectRowAt: unselectRowsSource,
                        enableCompareButton: enableCompareSource)
    }
    
}

extension CurrencyConverterOverviewViewModel {
    
    struct Output {
        let title: String
        let initialEurosValue: String
        let items: Driver<[CurrencyConverterValueCellViewModel]>
        let unselectRowAt: Observable<Int>
        let enableCompareButton: Observable<Bool>
    }
    
    struct UIInput {
        let eurosValueEntered: Observable<String?>
        let itemSelected: Observable<IndexPath>
        let itemDeselected: Observable<IndexPath>
    }
}

extension CurrencyConverterOverviewViewModel: CurrencyConverterOverviewViewModelProtocol {
    
    var title: String {
        output.title
    }
    
    var initialEurosValue: String {
        output.initialEurosValue
    }
    
    var items: Driver<[CurrencyConverterValueCellViewModel]> {
        output.items
    }
    
    var unselectRowAt: Observable<Int> {
        output.unselectRowAt
    }
    var enableCompareButton: Observable<Bool> {
        output.enableCompareButton
    }
    
    func isValidInput(currentText: String?, inputText: String, range: NSRange) -> Bool {
        
        let decimalSeperator = Locale.current.decimalSeparator ?? "."
        var allowedCharacters = "123456789"
        allowedCharacters.append(decimalSeperator)
        let numberSet = CharacterSet(charactersIn: allowedCharacters).inverted

        guard let oldText = currentText,
            let range = Range(range, in: oldText),
            inputText.rangeOfCharacter(from: numberSet) == nil else {
                return false
        }

        let newText = oldText.replacingCharacters(in: range, with: inputText)
        let numberOfDots = newText.components(separatedBy: decimalSeperator).count - 1
        let numberOfDecimalDigits: Int

        if let dotIndex = newText.firstIndex(of: Character(decimalSeperator)) {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        return numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
    
}
