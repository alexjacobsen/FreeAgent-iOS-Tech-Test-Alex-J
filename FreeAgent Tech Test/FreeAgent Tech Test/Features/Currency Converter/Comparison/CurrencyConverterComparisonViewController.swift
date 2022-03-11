import RxSwift
import Foundation

class CurrencyConverterComparisonViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var sortButton: UIButton!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(types: [CurrencyConverterComparisonCell.self])
            tab;
        }
    }
    
    var viewModelFactory: (CurrencyConverterComparisonViewModel.UIInput) -> CurrencyConverterComparisonViewModelProtocol = { _ in
        fatalError("`viewModelFactory` must be assigned after initialising viewController")
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var viewModel: CurrencyConverterComparisonViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = CurrencyConverterComparisonViewModel.UIInput(sortButtonTapped: sortButton.rx.tap.asObservable())
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = 50
        
        bind(viewModelFactory(input))
    }
    
    private func hideLoadingView() {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.loadingView.isHidden = true
            self?.stackView.isHidden = false
        }
    }
    
    private func displayAlert(config: AlertConfig) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: .alert)
            
            for action in config.actions {
                alert.addAction(action)
            }
            
            // Present Alert to
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func bind(_ viewModel: CurrencyConverterComparisonViewModelProtocol) {
        self.viewModel = viewModel
        self.navigationItem.title = viewModel.title
        let cellType = CurrencyConverterComparisonCell.self
        
        /// Drive the items in the table view from the data source in the view model
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: cellType.reuseIdentifier, cellType: cellType)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        /// Hide the loading view when determined by the view model
        viewModel.hideLoadingView.subscribe(onNext: { [weak self] in
            self?.hideLoadingView()
        })
        
        /// Display an allert with the config passed by the view model
        viewModel.showAlert.subscribe(onNext: { [weak self] config in
            self?.displayAlert(config: config)
        })
    }
}

extension CurrencyConverterComparisonViewController: Storyboardable {
    
    static var storyboardIdentifier: String? {
        "CurrencyConverterComparison"
    }
    
    static var storyboardName: String {
        "CurrencyConverter"
    }
    
}

