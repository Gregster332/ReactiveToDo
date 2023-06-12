// 
//  ListViewController.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

protocol ListViewControllerProtocol: AnyObject {
}

final class ListViewController: UIViewController, ListViewControllerProtocol {
    
    // MARK: - Properties
    // swiftlint:disable implicitly_unwrapped_optional
    var viewModel: ListViewModel!
    // swiftlint:enable implicitly_unwrapped_optional
    private let searchingText = BehaviorRelay<String>(value: "")
    private let flaggedOnly = BehaviorRelay<Bool>(value: false)
    private let disposedBag = DisposeBag()
    private let categoryType: ToDoCategories
    
    // MARK: - Views
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    private let flaggedOnlyButton = UIButton(type: .custom)
    private let addButton = UIButton(type: .custom)
    private let spinner = UIActivityIndicatorView(style: .medium)
    var dataSource: RxTableViewSectionedReloadDataSource<ToDoSection>!
    
    init(categoryType: ToDoCategories) {
        self.categoryType = categoryType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
        bindViewModel()
        setupNaviationItems()
        setupView()
        setupConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addButton.frame.size.width = 40
        flaggedOnlyButton.frame.size.width = 40
    }
    
    func bindTableView() {
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueCell(withClass: ListCell.self, for: indexPath) as ListCell
            cell.configureWith(title: item.title, description: item.subtitle, date: item.endDate, flaged: item.flagged, isExpiredSoon: item.isExpiredSoon)
            return cell
        })
        
        dataSource.canEditRowAtIndexPath = { _, _ in
            return true
        }
        
        searchBar.rx.text
            .orEmpty
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] key in
                self?.searchingText.accept(key)
            })
            .disposed(by: disposedBag)

        flaggedOnlyButton.rx.tap
            .asObservable()
            .do(onNext: { [weak self] _ in
                if let value = self?.flaggedOnly.value {
                    let buttonImage = value ? UIImage(systemName: "flag") : UIImage(systemName: "flag.fill")
                    self?.flaggedOnlyButton.setImage(buttonImage, for: .normal)
                }
            })
            .subscribe(onNext: { [weak self] _ in
                if let value = self?.flaggedOnly.value {
                    self?.flaggedOnly.accept(!value)
                }
            })
            .disposed(by: disposedBag)
        
    }
}

// MARK: - Private Methods
private extension ListViewController {
    
    func bindViewModel() {
        let input = viewModel.transform(ListViewModel.Input(
            searchigKey: searchingText.asDriver(onErrorJustReturn: ""),
            flaggedOnly: flaggedOnly.asDriver(onErrorJustReturn: false),
            deleteItem:  tableView.rx.itemDeleted,
            selectItem: tableView.rx.itemSelected,
            createNewItem: addButton.rx.tap)
        )
        input.listItems
            .do(onNext: { [weak self] value in
                self?.spinner.isHidden = !value.isEmpty
                self?.tableView.isHidden = value.isEmpty
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposedBag)
        
        input.hideFlaggedButton
            .bind { value in
                self.flaggedOnlyButton.isHidden = value
            }
            .disposed(by: disposedBag)
        
        viewModel.emitFlagged()
    }
    
    func setupView() {
        
        self.do {
            $0.title = categoryType.rawValue.capitalized
        }
        
        view.do {
            $0.backgroundColor = .white
        }
        
        tableView.do {
            $0.register(cellWithClass: ListCell.self)
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.separatorStyle = .none
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 600
        }
        
        searchBar.do {
            $0.searchBarStyle = .default
            $0.placeholder = "Search..."
            $0.sizeToFit()
            $0.isTranslucent = false
            $0.backgroundImage = UIImage()
            tableView.tableHeaderView = searchBar
        }
        
        flaggedOnlyButton.do {
            $0.setImage(UIImage(systemName: "flag"), for: .normal)
        }
        
        addButton.do {
            $0.setImage(UIImage(systemName: "plus.app"), for: .normal)
        }
    }
    
    func setupNaviationItems() {
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: addButton), UIBarButtonItem(customView: flaggedOnlyButton)]
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupConstraints() {
        view.addSubview(spinner)
        view.addSubview(tableView)
        
        spinner.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.verticalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    func layoutSection() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 8, bottom: 16, trailing: 8)
        section.interGroupSpacing = spacing
        
        return section
    }
}

extension Reactive where Base == UIView {
    func fade(duration: TimeInterval) -> Observable<UIView> {
        return Observable.create { (observer) -> Disposable in
            UIView.animate(withDuration: duration, animations: {
                self.base.alpha = 0
            }, completion: { (_) in
                observer.onNext((self.base))
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}
