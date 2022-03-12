import XCTest
import RxSwift
import RxTest

@testable import FreeAgent_Tech_Test

class CurrencyConverterOverviewViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var disposeBag: DisposeBag!
    private var testScheduler: TestScheduler!
    private var cellViewModelObserver: TestableObserver<[CurrencyConverterOverviewCellViewModel]>!
    private var sortTappedTrigger: PublishSubject<Void>! = PublishSubject<Void>()
    private var viewModel: CurrencyConverterOverviewViewModel!
    
    private var navigateToComparisonExpectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
        cellViewModelObserver = testScheduler.createObserver([CurrencyConverterOverviewCellViewModel].self)
        sortTappedTrigger = PublishSubject<Void>()
        
        navigateToComparisonExpectation =  self.expectation(description: "Navigated to the comparison screen")
    }
    
    override func tearDown() {
        cellViewModelObserver = nil
        testScheduler = nil
        viewModel = nil
        navigateToComparisonExpectation = nil
        super.tearDown()
    }
    
    func testSelectingTwoValuesAllowsForNavigatingToComparison() {
        /// In order to compare rates the table must be populated with and two rates must be selected in the tableview.
        /// We know that there will be 10 values in the table once a base Eueos value is typed in (as this is hardcoded to meet the task spec).
        
        let eurosValueEnteredPublishSubject = PublishSubject<String?>()
        let itemSelectedPublishSubject = PublishSubject<IndexPath>()
        let compareButtonTappedPublishSubject = PublishSubject<Void>()
        navigateToComparisonExpectation.isInverted = false
        
        let input = CurrencyConverterOverviewViewModel.UIInput(eurosValueEntered: eurosValueEnteredPublishSubject,
                                                               itemSelected: itemSelectedPublishSubject,
                                                               itemDeselected: nil,
                                                               compareButtonTapped: compareButtonTappedPublishSubject)
        
        let viewModel = generateViewModel(input: input,
                                          navigateToComparison: { [weak self] _ in self?.navigateToComparisonExpectation.fulfill() },
                                          cellViewModelsSource: PublishSubject<Observable<[CurrencyConverterOverviewCellViewModel]>>(),
                                          client: MockFixerIOClient())
        // Simulate user interactions
        
        // 1. Enter a base currency value
        eurosValueEnteredPublishSubject.onNext("100")
        
        // 2. Select two rows from the table
        itemSelectedPublishSubject.onNext(IndexPath(row: 1, section: 0))
        itemSelectedPublishSubject.onNext(IndexPath(row: 2, section: 0))
        
        // 3. Tap compare button
        compareButtonTappedPublishSubject.onNext(())
        
        waitForExpectations()
    }
    
    /// GIVEN:  The fixer latest rates endpoint is called
    ///
    /// WHEN: The rates are known and mocked (as below)
    ///
    /// THEN: The cell view models should contain the specified currencies and their new value once the base currency value is multiplied by the supplied rates
    func testGetLatestCurrencyRatesSuccess() {
        navigateToComparisonExpectation.isInverted = true
        
        let expectedResult: [CurrencyConverterOverviewCellViewModel] = [CurrencyConverterOverviewCellViewModel(title: "USD",
                                                                                                               value: "100.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "EUR",
                                                                                                               value: "100.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "JPY",
                                                                                                               value: "400.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "GBP",
                                                                                                               value: "600.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "AUD",
                                                                                                               value: "200.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "CAD",
                                                                                                               value: "300.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "CHF",
                                                                                                               value: "500.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "CNY",
                                                                                                               value: "700.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "SEK",
                                                                                                               value: "800.0"),
                                                                        CurrencyConverterOverviewCellViewModel(title: "NZD",
                                                                                                               value: "900.0")]
        let mockClient = MockFixerIOClient(dateString: "2022-03-06",
                                           usdExchangeRate: 1.0,
                                           audExchangeRate: 2.0,
                                           cadExchangeRate: 3.0,
                                           jpyExchangeRate: 4.0,
                                           chfExchangeRate: 5.0,
                                           gbpExchangeRate: 6.0,
                                           cnyExchangeRate: 7.0,
                                           sekExchangeRate: 8.0,
                                           nzdExchangeRate: 9.0)
        
        wait { expectation in
            getLatestCurrencyRates(eurosBaseValue: 100.0,
                                   client: mockClient,
                                   expectation: expectation,
                                   expectedResult: expectedResult)
        }
    }
    
}

private extension CurrencyConverterOverviewViewModelTests {
    
    private func getLatestCurrencyRates(eurosBaseValue: Double,
                                        client: MockFixerIOClient,
                                        expectation: XCTestExpectation,
                                        expectedResult: [CurrencyConverterOverviewCellViewModel]) {
        let cellViewModelsSource = PublishSubject<Observable<[CurrencyConverterOverviewCellViewModel]>>()
        let cellViewModelsObservable: Observable<[CurrencyConverterOverviewCellViewModel]> = cellViewModelsSource.switchLatest()
        
        cellViewModelsObservable.subscribe(onNext: { currencies in
            
            defer {
                expectation.fulfill()
            }
            
            XCTAssertEqual(currencies, expectedResult)
            
        }).disposed(by: disposeBag)
        
        viewModel = generateViewModel(input: .init(eurosValueEntered: .just(String(eurosBaseValue)),
                                                          itemSelected: .just(IndexPath(row: 0, section: 0)),
                                                          itemDeselected: nil,
                                                          compareButtonTapped: .never()),
                                             cellViewModelsSource: cellViewModelsSource,
                                             client: client)
    }
}

private extension CurrencyConverterOverviewViewModelTests {
    
    func getUIInput(sortButtonTapped: Observable<Void> = .never()) -> CurrencyConverterOverviewViewModel.UIInput {
        CurrencyConverterOverviewViewModel.UIInput(eurosValueEntered: .just("100"),
                                                   itemSelected: .just(IndexPath(row: 0, section: 0)),
                                                   itemDeselected: nil,
                                                   compareButtonTapped: .never())
    }
    
    @discardableResult
    func generateViewModel(input: CurrencyConverterOverviewViewModel.UIInput,
                                  navigateToComparison: @escaping (CurrencyConverterComparisonConfig) -> Void = { _ in },
                                  cellViewModelsSource: PublishSubject<Observable<[CurrencyConverterOverviewCellViewModel]>>,
                                  client: MockFixerIOClient) -> CurrencyConverterOverviewViewModel {
        
        viewModel = CurrencyConverterOverviewViewModel(input: input,
                                                       dependencies: .init(title: "Title",
                                                                           navigateToComparison: navigateToComparison,
                                                                           client: client,
                                                                           cellViewModelsSource: cellViewModelsSource))
        
        viewModel.items
            .drive(cellViewModelObserver)
            .disposed(by: disposeBag)
        
        return viewModel
    }
    
    func waitForExpectations() {
        wait(for: [navigateToComparisonExpectation],
             timeout: 1.0)
    }
}



