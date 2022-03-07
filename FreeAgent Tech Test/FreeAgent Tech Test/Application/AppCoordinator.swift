import UIKit

enum AppChildCoordinator {
    case currencyConverter
}

final class AppCoordinator: Coordinator {

    // MARK: - Properties -
//    var dependencies: Dependencies
//    internal let actions: Actions
    var rootViewController: UIViewController?
    var dependencies: Dependencies
    
    // Private variables
    private var coordinator: Coordinator?
    
    // MARK: - Initialiser -
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Public methods -
    func start() {
        launchAppRoot(with: .currencyConverter)
    }

    func reset() {
        coordinator = nil
    }

}

// MARK: - Private Implementation Details
internal extension AppCoordinator {

    func launchAppRoot(with route: AppChildCoordinator) {

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.goTo(route: route)
            self.dependencies.window.rootViewController = self.rootViewController
            self.dependencies.window.makeKeyAndVisible()
        }
    }

    func goTo(route: AppChildCoordinator) {
        
        switch route {
        
        case .currencyConverter:
            
            let navigationController = UINavigationController()
            let currencyConverterCoordinator = CurrencyConverterCoordinator(dependencies: .init(navigationController: navigationController))
            
            currencyConverterCoordinator.start()
            
            rootViewController = navigationController
            coordinator = currencyConverterCoordinator
        }
    }
}

extension AppCoordinator {
    struct Dependencies {
        let window: UIWindow
    }
}

private extension AppCoordinator {
    
    var activeNavigationController: UINavigationController? {
        return [rootViewController as? UINavigationController]
            .compactMap { $0 }
            .first
    }
}


