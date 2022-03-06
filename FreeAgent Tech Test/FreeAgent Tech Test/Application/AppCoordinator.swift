import UIKit

enum AppChildCoordinator {
    case home
}

final class AppCoordinator: Coordinator {

    // MARK: - Properties -
//    var dependencies: Dependencies
//    internal let actions: Actions
    var rootViewController: UIViewController?
    
    // Private variables
    private var coordinator: Coordinator?
    
    // MARK: - Public methods -
    func start() {
        launchAppRoot(with: .home)
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
        }
    }

    func goTo(route: AppChildCoordinator) {
        
        switch route {
        
        case .home:
            
            let navigationController = UINavigationController()
            let currencyConverterCoordinator = CurrencyConverterCoordinator(dependencies: .init(navigationController: navigationController))
            
            currencyConverterCoordinator.start()
            
            rootViewController = UINavigationController()
            coordinator = currencyConverterCoordinator
        }
    }
}

private extension AppCoordinator {
    
    var activeNavigationController: UINavigationController? {
        return [rootViewController as? UINavigationController,
                (rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController]
            .compactMap { $0 }
            .first
    }
}


