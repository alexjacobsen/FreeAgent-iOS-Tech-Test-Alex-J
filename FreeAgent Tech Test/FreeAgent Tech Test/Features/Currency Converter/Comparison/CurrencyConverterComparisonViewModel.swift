import RxSwift
import RxCocoa
import UIKit

protocol CurrencyConverterComparisonViewModelProtocol {
    var title: String { get }
    var items: Driver<[CurrencyConverterComparisonCellViewModel]> { get }
    var headerViewModel: CurrencyConverterComparisonHeaderViewModel { get }
    var hideLoadingView: Observable<Void> { get }
    var showAlert: Observable<AlertConfig> { get }
}

private enum TableItem {
    case currencyComparisonCell(_ viewModel: CurrencyConverterComparisonCellViewModel)
}

struct CurrencyConverterComparisonConfig {
    let baseCurrencySymbol: CurrencySymbol
    let currencyOneSymbol: CurrencySymbol
    let currencyTwoSymbol: CurrencySymbol
}

struct CurrencyConverterComparisonViewModel {
    
    private let disposeBag = DisposeBag()
    private let output: Output
    private let numberOfPastDays = 5
        
    init(input: UIInput, dependencies: Dependencies) {
        
        // MARK:- Observables
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterComparisonCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterComparisonCellViewModel]> = cellViewModelsSource.switchLatest()
        
        let hideLoadingView = PublishSubject<Void>()
        let showAlert = PublishSubject<AlertConfig>()
        let showSortMenu = PublishSubject<AlertConfig>()
                
        // MARK:- Other Properties
        var cellViewModels = [CurrencyConverterComparisonCellViewModel]()
    
        // MARK:- Networking
        
        let apiResultsObservable = getHistoricalRates(client: dependencies.client,
                                                      numberOfPastDays: numberOfPastDays,
                                                      config: dependencies.config)
        
        // Success
        apiResultsObservable.subscribe(onNext: { currencies in
            let viewModels = currencies.map { CurrencyConverterComparisonCellViewModel(date: $0.date,
                                                                                       currencyOneValue: String($0.rates[0].value),
                                                                                       currencyTwoValue: String($0.rates[1].value)) }
            cellViewModels = viewModels
            cellViewModelsSource.onNext(.just(cellViewModels))
            
            hideLoadingView.onNext(())
        }).disposed(by: disposeBag)

        // Failure
        apiResultsObservable.subscribe(onError: { currencies in
            hideLoadingView.onNext(())
            showAlert.onNext(AlertConfig.networkErrorAlertConfig(retryHandler: { _ in  }))
        }).disposed(by: disposeBag)
        
   
        let items = cellViewModelsObservable.share(replay: 1)
        
        // MARK:- Inputs
        
        input.sortButtonTapped.subscribe(onNext: {
            // TODO: finish sort functionality
//            showSortMenu.onNext(AlertConfig.sortCurrencyComparisonAlertConfig(actions: sortMenuActions()))
        })
        .disposed(by: disposeBag)
        
        
        // MARK:- Outputs
        output = Output(title: dependencies.title,
                        items: items.asDriverOrAssertionFailure(),
                        headerViewModel: .init(dateTitle: "Date",
                                               currencyOneTitle: dependencies.config.currencyOneSymbol.rawValue,
                                               currencyTwoTitle: dependencies.config.currencyTwoSymbol.rawValue),
                        hideLoadingView: hideLoadingView,
                        showAlert: showAlert)
    }
    
}

private func getHistoricalRates(client: FixerIOClient,
                                numberOfPastDays: Int,
                                config: CurrencyConverterComparisonConfig) -> Observable<[Currency]> {
    var observables = [Observable<Currency>]()
    for dayCounter in 1...numberOfPastDays {
        let date = Calendar.current.date(byAdding: .day, value: -dayCounter, to: Date())
        guard let dateString = date?.yearLongMonthShortDayShort,
              let formattedDate = DateFormatter.yearLongMonthShortDayShort.date(from: dateString) else { fatalError("A date string should be generated as there should be a date")}
        
        observables.append(client.getHistoricalExchangeRates(for: formattedDate,
                                                             base: config.baseCurrencySymbol,
                                                             symbols: [config.currencyOneSymbol, config.currencyTwoSymbol]))
    }
    
    return Observable.zip(observables)
}

// TODO: finish sort functionality
//private func sortMenuActions(cellViewModels: [CurrencyConverterComparisonCellViewModel]) -> ([UIAlertAction], [CurrencyConverterComparisonCellViewModel]) {
//
////    UIAlertAction(title: "Date - Ascending",
////                  style: .default,
////                  handler: { _ in
////                    return sortByDateAscending(cellViewModels: cellViewModels)
////                  })
////    return
//}

//private func sortByDateAscending(cellViewModels: [CurrencyConverterComparisonCellViewModel]) -> (() -> [CurrencyConverterComparisonCellViewModel]) {
//    var cellViewModels = cellViewModels
//    let formatter = DateFormatter()
//    cellViewModels.sort { formatter.date(from: $0.date)! < formatter.date(from: $1.date)! }
//}
//private func sortByDateDescending(cellViewModels: [CurrencyConverterComparisonCellViewModel]) -> (() -> [CurrencyConverterComparisonCellViewModel]) {
//    var cellViewModels = cellViewModels
//    let formatter = DateFormatter()
//    cellViewModels.sort { formatter.date(from: $0.date)! > formatter.date(from: $1.date)! }
//}

extension CurrencyConverterComparisonViewModel {
    
    struct Dependencies {
        let title: String
        let config: CurrencyConverterComparisonConfig
        let client: FixerIOClient
    }
}

extension CurrencyConverterComparisonViewModel {
    
    struct Output {
        let title: String
        let items: Driver<[CurrencyConverterComparisonCellViewModel]>
        let headerViewModel: CurrencyConverterComparisonHeaderViewModel
        let hideLoadingView: Observable<Void>
        let showAlert: Observable<AlertConfig>
    }
    
    struct UIInput {
        let sortButtonTapped: Observable<Void>
    }
}

extension CurrencyConverterComparisonViewModel: CurrencyConverterComparisonViewModelProtocol {
    
    var title: String {
        output.title
    }
    
    var items: Driver<[CurrencyConverterComparisonCellViewModel]> {
        output.items
    }
    
    var headerViewModel: CurrencyConverterComparisonHeaderViewModel {
        output.headerViewModel
    }
    
    var hideLoadingView: Observable<Void> {
        output.hideLoadingView
    }
    
    var showAlert: Observable<AlertConfig> {
        output.showAlert
    }
    
}

