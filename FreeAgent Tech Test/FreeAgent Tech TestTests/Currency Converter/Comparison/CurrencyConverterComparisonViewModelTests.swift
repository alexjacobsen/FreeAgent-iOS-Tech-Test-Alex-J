import XCTest
import RxSwift
import RxTest

@testable import FreeAgent_Tech_Test

class CurrencyConverterComparisonViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var disposeBag: DisposeBag!
    private var testScheduler: TestScheduler!
    private var cellViewModelObserver: TestableObserver<[CurrencyConverterComparisonCellViewModel]>!
    private var sortTappedTrigger: PublishSubject<Void>! = PublishSubject<Void>()
    private var viewModel: CurrencyConverterComparisonViewModel!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
        cellViewModelObserver = testScheduler.createObserver([CurrencyConverterComparisonCellViewModel].self)
        sortTappedTrigger = PublishSubject<Void>()
    }
    
    override func tearDown() {
        cellViewModelObserver = nil
        testScheduler = nil
        viewModel = nil
        super.tearDown()
    }
    
    /// GIVEN:  The fixer historical rates end point is called for the `AUD` and `GBP` currencies.
    /// WHEN: The date is set to `2022-03-06` and the AUD rate is `12.0` and the GBP rate is `19.0`.
    /// THEN: The API call should return an array of `5` cell view models with the rates mentioned above.
    func testGetHistoricalCurrencyRatesSuccess() {
        
        // The View model is hardcoded to only retrieve the past 5 days
        let expectedResult: [CurrencyConverterComparisonCellViewModel] = Array(repeating: CurrencyConverterComparisonCellViewModel(date: "2022-03-06",
                                                                                                                                   currencyOneRate: .init(title: .aud, value: 12.0),
                                                                                                                                   currencyTwoRate: .init(title: .gbp, value: 19.0)), count: 5)
        let mockClient = MockFixerIOClient(dateString: "2022-03-06",
                                           audExchangeRate: 12.0,
                                           gbpExchangeRate: 19.0)
        
        wait { expectation in
            getHistoricalCurrencyRates(config: .init(baseCurrencySymbol: .eur,
                                                     currencyOneSymbol: .aud,
                                                     currencyTwoSymbol: .gbp),
                                       client: mockClient,
                                       expectation: expectation,
                                       expectedResult: expectedResult)
        }
    }
    
}

private extension CurrencyConverterComparisonViewModelTests {
    
    private func getHistoricalCurrencyRates(config: CurrencyConverterComparisonConfig,
                                            client: MockFixerIOClient,
                                            expectation: XCTestExpectation,
                                            expectedResult: [CurrencyConverterComparisonCellViewModel]) {
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterComparisonCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterComparisonCellViewModel]> = cellViewModelsSource.switchLatest()
        
        cellViewModelsObservable.subscribe(onNext: { currencies in
            
            defer {
                expectation.fulfill()
            }
            
            XCTAssertEqual(currencies, expectedResult)
            
        }).disposed(by: disposeBag)
        
        viewModel = generateViewModel(input: getUIInput(),
                                             config: config,
                                             cellViewModelsSource: cellViewModelsSource,
                                             client: client)
    }
}

private extension CurrencyConverterComparisonViewModelTests {
    
    func getUIInput(sortButtonTapped: Observable<Void> = .never()) -> CurrencyConverterComparisonViewModel.UIInput {
        CurrencyConverterComparisonViewModel.UIInput(sortButtonTapped: sortButtonTapped)
    }
    
    @discardableResult
    func generateViewModel(input: CurrencyConverterComparisonViewModel.UIInput,
                                  config: CurrencyConverterComparisonConfig,
                                  cellViewModelsSource: PublishSubject<Observable<[CurrencyConverterComparisonCellViewModel]>>,
                                  client: MockFixerIOClient) -> CurrencyConverterComparisonViewModel {
        
        viewModel = CurrencyConverterComparisonViewModel(input: input,
                                                         dependencies: .init(title: "",
                                                                             config: CurrencyConverterComparisonConfig(baseCurrencySymbol: config.baseCurrencySymbol,
                                                                                                                       currencyOneSymbol: config.currencyOneSymbol,
                                                                                                                       currencyTwoSymbol: config.currencyTwoSymbol),
                                                                             client: client,
                                                                             cellViewModelsSource: cellViewModelsSource))
        
        viewModel.items
            .drive(cellViewModelObserver)
            .disposed(by: disposeBag)
        
        return viewModel
    }
    
}


