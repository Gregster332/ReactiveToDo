// 
//  MainViewController.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import SnapKit
import RxSwift
import RealmSwift
import RxRealm
import RxDataSources

protocol MainViewControllerProtocol: AnyObject {
}

final class MainViewController: UIViewController, MainViewControllerProtocol {
    
    // MARK: - Properties
    
    // swiftlint:disable implicitly_unwrapped_optional
    var presenter: MainPresenterProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    private let disposedBag = DisposeBag()
    
    // MARK: - Views
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchBar = UISearchBar()
    private let flaggedOnlyButton = UIButton(type: .custom)
    var dataSource: RxTableViewSectionedReloadDataSource<ToDoSection>!
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
        presenter.getAllTodos()
    }
    
    func bindTableView() {
        
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueCell(withClass: ToDoCell.self, for: indexPath) as ToDoCell
            cell.configureWith(title: item.title, description: item.subtitle, date: item.endDate.toString(), flaged: item.flagged)
            return cell
        })
        
        dataSource.canEditRowAtIndexPath = { _, _ in
            return true
        }
        
        disposedBag.insert(
        presenter.listItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
        )
        
//        tableView.rx
//            .setDelegate(self)
//            .disposed(by: disposedBag)
        
        tableView.rx
            .itemSelected
            .map { $0 }
            .subscribe(onNext: { [weak self] index in
                let object = self?.presenter.listItems.value[index.section].items[index.item]
                self?.presenter.openToDo(toDo: object)
            })
            .disposed(by: disposedBag)
        
        tableView.rx
            .itemDeleted
            .asObservable()
            .share(replay: 1)
            .subscribe(onNext: { [weak self] item in
                self?.presenter.deleteItem(item: item)
            })
            .disposed(by: disposedBag)
        
        searchBar.rx.text
            .orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] key in
                self?.presenter.searchigKey.accept(key)
            })
            .disposed(by: disposedBag)
        
        flaggedOnlyButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let lastValue = self?.presenter.flaggedOnly.value {
                    self?.flaggedOnlyButton.setImage(
                        !lastValue ? UIImage(systemName: "flag.fill") : UIImage(systemName: "flag"),
                        for: .normal
                    )
                    self?.presenter.flaggedOnly.accept(!lastValue)
                }
            })
            .disposed(by: disposedBag)
        
    }
}

// MARK: - Private Methods

private extension MainViewController {
    
    func setupView() {
        
        self.do {
            $0.title = "Reminders"
        }
        
        view.do {
            $0.backgroundColor = .white
        }
        
        tableView.do {
            $0.register(cellWithClass: ToDoCell.self)
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
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleTapOnPlusButton)
        )
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: flaggedOnlyButton), addButton]
        
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
        presenter.openToDo(toDo: nil)
    }
}

//extension MainViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}

//extension MainViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
//            return self.makeContextMenu(for: indexPath)
//        })
//    }
//
//    private func makeContextMenu(for index: IndexPath) -> UIMenu {
//        var actions = [UIAction]()
//
//        let action = UIAction(title: "Delete", attributes: [.destructive]) { _ in
//            let item = self.presenter.toDos.value[index.section].items[index.item]
//            //self.collectionView.reloadData()
//            self.presenter.deleteItem(item: item)
//        }
//        actions.append(action)
//        return UIMenu(title: "", children: actions)
//    }
//}
