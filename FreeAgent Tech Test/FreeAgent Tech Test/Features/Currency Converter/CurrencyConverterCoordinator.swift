import UIKit

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
    }
}

// MARK: - Private implementation
internal extension CurrencyConverterCoordinator {
    
    enum Stage {
        case overview
        case comparison
    }
    
    func goTo(_ stage: Stage) {
        switch stage {
        case .overview:
            let overviewViewController = CurrencyConverterOverviewViewController.create()
            overviewViewController.viewModelFactory = { input in
                return CurrencyConverterOverviewViewModel(input: input,
                                                          navigateToComparison: { [weak self] currenciesToCompare in
                                                            self?.goTo(.comparison)
                                                          })
            }
            dependencies.navigationController.show(overviewViewController, sender: self)
            return
            
        case .comparison:
            //            let comparisonViewController = CurrencyConverterComparisonViewController.create()
//            overviewViewController.viewModelFactory = { [unowned self] input in
//                return CurrencyConverterComparisonViewModel(input: input,
//                                                   sendEvent: self.actions.common.sendEvent,
//                                                   gotoEnergyUsage: { [weak self] in self?.goTo(.energyUsage) },
//                                                   gotoTou: { [weak self] in self?.goTo(.tou) },
//                                                   didTapBack: { [weak self] in self?.actions.didTapBack() },
//                                                   didAppear: { [weak self] in self?.clearChildCoordinator() })
//            }
//            dependencies.navigationController.push(comparisonViewController, sender: self)
        return
        
        }
    }
}
