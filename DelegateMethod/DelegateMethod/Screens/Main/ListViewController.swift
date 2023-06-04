// 
//  ListViewController.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import SnapKit
import RxSwift
import RealmSwift
import RxRealm
import RxDataSources

protocol ListViewControllerProtocol: AnyObject {
}

final class ListViewController: UIViewController, ListViewControllerProtocol {
    
    // MARK: - Properties
    // swiftlint:disable implicitly_unwrapped_optional
    var viewModel: ListViewModelProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    private let disposedBag = DisposeBag()
    private let categoryType: ToDoCategories
    
    // MARK: - Views
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    private let flaggedOnlyButton = UIButton(type: .custom)
    private var addButton = UIBarButtonItem()
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
        setupNaviationItems()
        setupView()
        setupConstraints()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAllTodos()
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
        
        disposedBag.insert(
        viewModel.representListItems()
            .bind(to: tableView.rx.items(dataSource: dataSource))
        )
        
        viewModel.representFlagButtonHide()
            .subscribe(onNext: { [weak self] isHidden in
                self?.flaggedOnlyButton.isHidden = isHidden
            })
            .disposed(by: disposedBag)
        
        tableView.rx
            .itemSelected
            .map { $0 }
            .subscribe(onNext: { [weak self] index in
                self?.viewModel.openToDo(item: index)
            })
            .disposed(by: disposedBag)
        
        tableView.rx
            .itemDeleted
            .asObservable()
            .share(replay: 1)
            .subscribe(onNext: { [weak self] item in
                self?.viewModel.deleteItem(item: item)
            })
            .disposed(by: disposedBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] key in
                self?.viewModel.representSearchigKey().accept(key)
            })
            .disposed(by: disposedBag)
        
        flaggedOnlyButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let lastValue = self?.viewModel.representFlaggedOnly().value {
                    self?.flaggedOnlyButton.setImage(
                        !lastValue ? UIImage(systemName: "flag.fill") : UIImage(systemName: "flag"),
                        for: .normal
                    )
                    self?.viewModel.representFlaggedOnly().accept(!lastValue)
                }
            })
            .disposed(by: disposedBag)
        
    }
}

// MARK: - Private Methods
private extension ListViewController {
    
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
    }
    
    func setupNaviationItems() {
        addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleTapOnPlusButton)
        )
        navigationItem.rightBarButtonItems = [addButton, UIBarButtonItem(customView: flaggedOnlyButton)]
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        
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
    
    // MARK: - UI Actions
    @objc func handleTapOnPlusButton() {
        viewModel.openToDo(item: nil)
    }
}
