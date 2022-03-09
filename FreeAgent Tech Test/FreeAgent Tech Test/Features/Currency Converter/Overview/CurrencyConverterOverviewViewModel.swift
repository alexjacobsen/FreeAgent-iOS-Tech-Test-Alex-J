import RxSwift
import RxCocoa
import UIKit

protocol CurrencyConverterOverviewViewModelProtocol {
    var title: String { get }
    var initialEurosValue: String { get }
    var items: Driver<[CurrencyConverterValueCellViewModel]> { get }
    var unselectRowAt: Observable<Int> { get }
    var enableCompareButton: Observable<Bool> { get }
    var hideLoadingView: Observable<Void> { get }
    var showAlert: Observable<AlertConfig> { get }
    
    func isValidInput(currentText: String?, inputText: String, range: NSRange) -> Bool
}

enum TableItem {
    case currencyValueCell(_ viewModel: CurrencyConverterValueCellViewModel)
}

struct CurrencyConverterOverviewViewModel {
    
    private let disposeBag = DisposeBag()
    private let output: Output
        
    init(input: UIInput,
         navigateToComparison: @escaping ([CurrencyAbbreviation]) -> Void) {
        
        // MARK:- Observables
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterValueCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterValueCellViewModel]> = cellViewModelsSource.switchLatest()
        
        let unselectRowsSource = PublishSubject<Int>()
        let enableCompareSource = PublishSubject<Bool>()
        let hideLoadingView = PublishSubject<Void>()
        let showAlert = PublishSubject<AlertConfig>()
        
        let eurosValue = PublishSubject<Double>()
        
        // MARK:- Other Properties
        var euroCurrency: Currency?
        var cellViewModels = [CurrencyConverterValueCellViewModel]()
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
    
        // MARK:- Networking
        
        let result: Observable<Currency> = LatestExchangeRatesAPICall().send()
        
        // Success
        result.subscribe(onNext: { currency in
            euroCurrency = currency
            hideLoadingView.onNext(())
        }).disposed(by: disposeBag)
        
        // Failure
        result.subscribe(onError: { currencies in
            hideLoadingView.onNext(())
            showAlert.onNext(AlertConfig.networkErrorAlertConfig(retryHandler: { _ in  }))
        }).disposed(by: disposeBag)
        
        // MARK: - Publish Data Source Changes
        
        /// Subcribing to changes of the euros value allows us to build the datasource in the fly with the changes typed into the textfield
        eurosValue.subscribe(onNext: { eurosValue in
            guard let euroCurrency = euroCurrency else { return }
                        
            cellViewModels = euroCurrency.rates.map { (rate) -> CurrencyConverterValueCellViewModel in
                CurrencyConverterValueCellViewModel(title: rate.title.rawValue, value: String(rate.value * eurosValue))
            }
                        
            cellViewModelsSource.onNext(.just(cellViewModels))
        }).disposed(by: disposeBag)
        
        let items = cellViewModelsObservable.share(replay: 1)
        
        // MARK:- Inputs
                
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
        
        input.compareButtonTapped.subscribe(onNext: {
            var currenciesToCompare = [CurrencyAbbreviation]()
                        
            selectedCellIndexes.forEach {
                if let currencyAbreviation = euroCurrency?.rates[$0].title {
                    currenciesToCompare.append(currencyAbreviation)
                }
                
            }
            
            if currenciesToCompare.count == 2 {
                navigateToComparison(currenciesToCompare)
            } else {
                fatalError("It should not be possible to get here if there are notn exactly 2 currencies selected")
            }
            
        })
        .disposed(by: disposeBag)
        
        
        // MARK:- Outputs
        output = Output(title: "Currency Converter",
                        initialEurosValue: "100.70",
                        items: items.asDriverOrAssertionFailure(),
                        unselectRowAt: unselectRowsSource,
                        enableCompareButton: enableCompareSource,
                        hideLoadingView: hideLoadingView,
                        showAlert: showAlert)
    }
    
}

extension CurrencyConverterOverviewViewModel {
    
    struct Output {
        let title: String
        let initialEurosValue: String
        let items: Driver<[CurrencyConverterValueCellViewModel]>
        let unselectRowAt: Observable<Int>
        let enableCompareButton: Observable<Bool>
        let hideLoadingView: Observable<Void>
        let showAlert: Observable<AlertConfig>
    }
    
    struct UIInput {
        let eurosValueEntered: Observable<String?>
        let itemSelected: Observable<IndexPath>
        let itemDeselected: Observable<IndexPath>
        let compareButtonTapped: Observable<Void>
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
    
    var hideLoadingView: Observable<Void> {
        output.hideLoadingView
    }
    
    var showAlert: Observable<AlertConfig> {
        output.showAlert
    }
    
    func isValidInput(currentText: String?, inputText: String, range: NSRange) -> Bool {
        
        let characterLimit = 10
        let numberOfDotsLimit = 1
        let numberOfDecimalDigitsLimit = 2
        
        let decimalSeperator = Locale.current.decimalSeparator ?? "."
        var allowedCharacters = "1234567890"
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
        
        let isValid = numberOfDots <= numberOfDotsLimit &&
            numberOfDecimalDigits <= numberOfDecimalDigitsLimit &&
            newText.count <= characterLimit

        return isValid
    }
    
}
