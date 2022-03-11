import RxSwift
import RxCocoa
import UIKit

protocol CurrencyConverterComparisonViewModelProtocol {
    var title: String { get }
    var items: Driver<[CurrencyConverterComparisonCellViewModel]> { get }
    var hideLoadingView: Observable<Void> { get }
    var showAlert: Observable<AlertConfig> { get }
    
    func isValidInput(currentText: String?, inputText: String, range: NSRange) -> Bool
}

private enum TableItem {
    case currencyValueCell(_ viewModel: CurrencyConverterComparisonCellViewModel)
}

struct CurrencyConverterComparisonViewModel {
    
    private let disposeBag = DisposeBag()
    private let output: Output
        
    init(input: UIInput, dependencies: Dependencies) {
        
        // MARK:- Observables
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterComparisonCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterComparisonCellViewModel]> = cellViewModelsSource.switchLatest()
        
        let hideLoadingView = PublishSubject<Void>()
        let showAlert = PublishSubject<AlertConfig>()
        
        let eurosValue = PublishSubject<Double>()
        
        // MARK:- Other Properties
        var euroCurrency: Currency?
        var cellViewModels = [CurrencyConverterComparisonCellViewModel]()
    
        // MARK:- Networking
        
//        let pastDays = 3
//
//
//
//        let result1: Observable<Currency> = FixerIOClient().getHistoricalExchangeRates(for: DateFormatter.yearLongMonthShortDayShort.date(from: "2022-02-11")!,
//                                                                                       base: .gbp,
//                                                                                       symbols: [.aud, .cad])
//        let result2: Observable<Currency> = FixerIOClient().getHistoricalExchangeRates(for: DateFormatter.yearLongMonthShortDayShort.date(from: "2022-02-10")!,
//                                                                                       base: .gbp,
//                                                                                       symbols: [.aud, .cad])
//        let result3: Observable<Currency> = FixerIOClient().getHistoricalExchangeRates(for: DateFormatter.yearLongMonthShortDayShort.date(from: "2022-02-09")!,
//                                                                                       base: .gbp,
//                                                                                       symbols: [.aud, .cad])
//
//
//        let historicalAPICallsSuccceded = Observable.zip(result1, result2, result3)
//
//        historicalAPICallsSuccceded.subscribe(onNext: {
//
//
//        })
        
        // Success
//        result.subscribe(onNext: { currency in
//            euroCurrency = currency
//            hideLoadingView.onNext(())
//        }).disposed(by: disposeBag)
        
        // Failure
//        result.subscribe(onError: { currencies in
//            hideLoadingView.onNext(())
//            showAlert.onNext(AlertConfig.networkErrorAlertConfig(retryHandler: { _ in  }))
//        }).disposed(by: disposeBag)
        
        // MARK: - Publish Data Source Changes
        
        /// Subcribing to changes of the euros value allows us to build the datasource in the fly with the changes typed into the textfield
        eurosValue.subscribe(onNext: { eurosValue in
            guard let euroCurrency = euroCurrency else { return }
                        
            cellViewModels = euroCurrency.rates.map { (rate) -> CurrencyConverterComparisonCellViewModel in
                CurrencyConverterComparisonCellViewModel(title: rate.title.rawValue, value: String(rate.value * eurosValue))
            }
                        
            cellViewModelsSource.onNext(.just(cellViewModels))
        }).disposed(by: disposeBag)
        
        let items = cellViewModelsObservable.share(replay: 1)
        
        // MARK:- Inputs
        
        input.sortButtonTapped.subscribe(onNext: {
            var currenciesToCompare = [CurrencySymbol]()
                        
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
        output = Output(title: dependencies.title,
                        initialEurosValue: "100.70",
                        items: items.asDriverOrAssertionFailure(),
                        unselectRowAt: unselectRowsSource,
                        enableCompareButton: enableCompareSource,
                        hideLoadingView: hideLoadingView,
                        showAlert: showAlert)
    }
    
}

extension CurrencyConverterComparisonViewModel {
    
    struct Dependencies {
        let title: String
    }
}

extension CurrencyConverterComparisonViewModel {
    
    struct Output {
        let title: String
        let initialEurosValue: String
        let items: Driver<[CurrencyConverterComparisonCellViewModel]>
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

extension CurrencyConverterComparisonViewModel: CurrencyConverterComparisonViewModelProtocol {
    
    var title: String {
        output.title
    }
    
    var initialEurosValue: String {
        output.initialEurosValue
    }
    
    var items: Driver<[CurrencyConverterComparisonCellViewModel]> {
        output.items
    }
    
    var hideLoadingView: Observable<Void> {
        output.hideLoadingView
    }
    
    var showAlert: Observable<AlertConfig> {
        output.showAlert
    }
    
}

