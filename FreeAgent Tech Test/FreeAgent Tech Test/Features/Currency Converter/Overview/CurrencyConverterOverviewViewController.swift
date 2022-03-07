import RxSwift

class CurrencyConverterOverviewViewController: UIViewController {
    
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
    private let didTapBackSubject = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let input = CurrencyConverterOverviewViewModel.UIInput(eurosValueEntered: .just("50000"),
//                                                               itemSelected: tableView.rx.itemSelected.asObservable())
//        bind(viewModelFactory(input))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .never
        if isMovingFromParent {
            didTapBackSubject.onNext(())
        }
    }
    
    func bind(_ viewModel: CurrencyConverterOverviewViewModelProtocol) {
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
