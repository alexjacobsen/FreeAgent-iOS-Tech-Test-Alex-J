import RxSwift
import Foundation

class CurrencyConverterOverviewViewController: UIViewController {
    
    
    @IBOutlet private weak var eurosTextField: UITextField!
    @IBOutlet private weak var compareButton: UIButton!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(types: [CurrencyConverterValueCell.self])
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
                                                               itemDeselected: tableView.rx.itemDeselected.asObservable())
        bind(viewModelFactory(input))
        configureUI()
    }
    
    private func configureUI() {
        compareButton.layer.cornerRadius = 5
        compareButton.layer.borderWidth = 1
        compareButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func bind(_ viewModel: CurrencyConverterOverviewViewModelProtocol) {
        self.viewModel = viewModel
        self.navigationItem.title = viewModel.title
        let cellType = CurrencyConverterValueCell.self
        
        /// Drive the items in the table view from the data source in the view model
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: cellType.reuseIdentifier, cellType: cellType)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
        
        /// Unselect cells determined by the view model
        viewModel.unselectRowAt.subscribe(onNext: { [weak self] index in
            let indexPath = IndexPath(row: index, section: 0)
            let cell = self?.tableView.cellForRow(at: indexPath) as? CurrencyConverterValueCell
            
            cell?.setSelected(false, animated: false)
        })
        
        /// Unselect cells determined by the view model
        viewModel.enableCompareButton.subscribe(onNext: { [weak self] enableButton in
            self?.compareButton.isEnabled = enableButton
        })
    }
}

extension CurrencyConverterOverviewViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.isValidInput(currentText: textField.text, inputText: string, range: range)
    }
}

extension CurrencyConverterOverviewViewController: Storyboardable {
    
    static var storyboardIdentifier: String? {
        "CurrencyConverter"
    }
    
    static var storyboardName: String {
        "CurrencyConverter"
    }
    
}
