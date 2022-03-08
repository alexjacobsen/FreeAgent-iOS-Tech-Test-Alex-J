import RxSwift
import RxCocoa
import UIKit

protocol CurrencyConverterOverviewViewModelProtocol {
    var title: String { get }
    var initialEurosValue: String { get }
    var items: Driver<[CurrencyConverterValueCellViewModel]> { get }
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
        
        var selectedCell: CurrencyConverterValueCellViewModel?
        var cellViewModels = [CurrencyConverterValueCellViewModel]()
            
        eurosValue.onNext(100.0)
        
        // Subcribing to changes of the euros value allows us to build the datasource in the fly with the changes typed into the textfield
        eurosValue.subscribe(onNext: { eurosValue in
            guard let euroCurrency = currencies.currencies.first(where: { $0.base == .eur }) else { fatalError("Euros not available in response") }
                        
            cellViewModels = euroCurrency.rates.map { (rate) -> CurrencyConverterValueCellViewModel in
                CurrencyConverterValueCellViewModel(title: rate.title.rawValue, value: String(rate.value * eurosValue))
            }
                        
            cellViewModelsSource.onNext(.just(cellViewModels))
        }).disposed(by: disposeBag)
        
        let items = cellViewModelsObservable.share(replay: 1)
        
        Observable.combineLatest(items, input.itemSelected)
            .subscribe(onNext: { selectedCell = cellViewModels[$1.row] })
            .disposed(by: disposeBag)
                        
        input.eurosValueEntered.subscribe(onNext: { eurosString in
            if let eurosString = eurosString,
               let euros = Double(eurosString) {
                eurosValue.onNext(euros)
            }
        }).disposed(by: disposeBag)
        
        output = Output(title: "Currency Converter",
                        initialEurosValue: "100.70",
                        items: items.asDriverOrAssertionFailureInDebugAndEmptyInRelease())
    }
    
}

extension CurrencyConverterOverviewViewModel {
    
    struct Output {
        let title: String
        let initialEurosValue: String
        let items: Driver<[CurrencyConverterValueCellViewModel]>
    }
    
    struct UIInput {
        let eurosValueEntered: Observable<String?>
        let itemSelected: Observable<IndexPath>
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
    
}
