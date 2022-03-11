import RxSwift
import Foundation

class CurrencyConverterOverviewViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var eurosTextField: UITextField!
    @IBOutlet private weak var compareButton: UIButton!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(types: [CurrencyConverterOverviewCell.self])
        }
    }
    
    var viewModelFactory: (CurrencyConverterOverviewViewModel.UIInput) -> CurrencyConverterOverviewViewModelProtocol = { _ in
        fatalError("`viewModelFactory` must be assigned after initialising viewController")
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var viewModel: CurrencyConverterOverviewViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let input = CurrencyConverterOverviewViewModel.UIInput(eurosValueEntered: eurosTextField.rx.text.asObservable(),
                                                               itemSelected: tableView.rx.itemSelected.asObservable(),
                                                               itemDeselected: tableView.rx.itemDeselected.asObservable(),
                                                               compareButtonTapped: compareButton.rx.tap.asObservable())
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
    
    private func bind(_ viewModel: CurrencyConverterOverviewViewModelProtocol) {
        self.viewModel = viewModel
        self.navigationItem.title = viewModel.title
        let cellType = CurrencyConverterOverviewCell.self
        
        /// Drive the items in the table view from the data source in the view model
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: cellType.reuseIdentifier, cellType: cellType)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        /// Unselect cells determined by the view model
        viewModel.unselectRowAt.subscribe(onNext: { [weak self] index in
            let indexPath = IndexPath(row: index, section: 0)
            let cell = self?.tableView.cellForRow(at: indexPath) as? CurrencyConverterOverviewCell
            
            cell?.setSelected(false, animated: false)
        })
        
        /// Unselect cells determined by the view model
        viewModel.enableCompareButton.subscribe(onNext: { [weak self] enableButton in
            self?.compareButton.isEnabled = enableButton
        })
        
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

extension CurrencyConverterOverviewViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.isValidInput(currentText: textField.text, inputText: string, range: range)
    }
}

extension CurrencyConverterOverviewViewController: Storyboardable {
    
    static var storyboardName: String {
        "CurrencyConverter"
    }
    
}
