import UIKit
import RxSwift

final class CurrencyConverterCoordinator: Coordinator {
    
    // MARK: - Properties
    internal let dependencies: Dependencies
    
    // MARK: - Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func start() {
        goTo(.overview)
    }
}

// MARK: - Data structures
extension CurrencyConverterCoordinator {
    
    struct Actions {
        let didTapBack: () -> Void
    }
    
    struct Dependencies {
        let navigationController: UINavigationController
        let client: FixerIOClient
    }
}

// MARK: - Private implementation
internal extension CurrencyConverterCoordinator {
    
    enum Stage {
        case overview
        case comparison(config: CurrencyConverterComparisonConfig)
    }
    
    func goTo(_ stage: Stage) {
        switch stage {
        case .overview:
            let overviewViewController = CurrencyConverterOverviewViewController.create()
            overviewViewController.viewModelFactory = { input in
                return CurrencyConverterOverviewViewModel(input: input,
                                                          dependencies: .init(title: "Currency Converter",
                                                                              navigateToComparison: { [weak self] config in self?.goTo(.comparison(config: config))},
                                                                              client: self.dependencies.client))
            }
            dependencies.navigationController.show(overviewViewController, sender: self)
            return
            
        case .comparison(let config):
            let comparisonViewController = CurrencyConverterComparisonViewController.create()
            comparisonViewController.viewModelFactory = { [unowned self] input in
                return CurrencyConverterComparisonViewModel(input: input,
                                                            dependencies: .init(title: "Currency Comparison",
                                                                                config: config,
                                                                                client: self.dependencies.client, cellViewModelsSource: PublishSubject<Observable<[CurrencyConverterComparisonCellViewModel]>>()))
            }
            dependencies.navigationController.pushViewController(comparisonViewController, animated: true)
        return
        
        }
    }
}
