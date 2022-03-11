import RxSwift
import RxCocoa
import UIKit

protocol CurrencyConverterComparisonViewModelProtocol {
    var title: String { get }
    var items: Driver<[CurrencyConverterComparisonCellViewModel]> { get }
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
        
    init(input: UIInput, dependencies: Dependencies) {
        
        // MARK:- Observables
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterComparisonCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterComparisonCellViewModel]> = cellViewModelsSource.switchLatest()
        
        let hideLoadingView = PublishSubject<Void>()
        let showAlert = PublishSubject<AlertConfig>()
                
        // MARK:- Other Properties
        var cellViewModels = [CurrencyConverterComparisonCellViewModel]()
    
        // MARK:- Networking
        
        let apiResultsObservable = getHistoricalRates(client: dependencies.client,
                                                      numberOfPastDays: 2,
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
            //TODO: add sort functionality
        })
        .disposed(by: disposeBag)
        
        
        // MARK:- Outputs
        output = Output(title: dependencies.title,
                        items: items.asDriverOrAssertionFailure(),
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
    
    var hideLoadingView: Observable<Void> {
        output.hideLoadingView
    }
    
    var showAlert: Observable<AlertConfig> {
        output.showAlert
    }
    
}

