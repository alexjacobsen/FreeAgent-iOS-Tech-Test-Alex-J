import RxSwift

class CurrencyConverterOverviewViewController: UIViewController {
    
    
    @IBOutlet private weak var eurosTextField: UITextField!
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
                                                               itemSelected: tableView.rx.itemSelected.asObservable())
        bind(viewModelFactory(input))
        
        configureUI()
    }
    
    private func configureUI() {
        eurosTextField.text = viewModel.initialEurosValue
    }
    
    private func bind(_ viewModel: CurrencyConverterOverviewViewModelProtocol) {
        self.viewModel = viewModel
        self.navigationItem.title = viewModel.title
        let cellType = CurrencyConverterValueCell.self
        
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: cellType.reuseIdentifier,
                                           cellType: cellType)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
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
