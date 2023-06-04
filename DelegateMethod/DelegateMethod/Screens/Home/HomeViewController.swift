// 
//  HomeViewController.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/31/23.
//

import RxDataSources
import RxSwift

struct HomeSection: SectionModelType {
    var items: [Item]
    
    init(original: HomeSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(items: [Item]) {
        self.items = items
    }
    
    struct Item {
        let name: String
        let image: UIImage
        let count: Int
    }
}

protocol HomeViewControllerProtocol: AnyObject {
}

final class HomeViewController: UIViewController, HomeViewControllerProtocol {
    
    // MARK: - Properties
    var viewModel: HomeViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    // MARK: - Views
    lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (index, _) -> NSCollectionLayoutSection? in
            return self.createSectionLayout()
        }
        return layout
    }()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavBar()
        setupConstraints()
        bindUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAllCells()
    }
}

// MARK: - Private Methods
private extension HomeViewController {
    
    func bindUI() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection> { dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueCell(with: indexPath) as HomeCell
            cell.configure(with: item)
            return cell
        }
        
        viewModel.representSections()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .asObservable()
            .subscribe(onNext: { index in
                self.viewModel.selectItem(with: index)
            })
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        
        self.do {
            $0.title = "Reminders"
        }
        
        view.do {
            $0.backgroundColor = .white
        }
        
        collectionView.do {
            $0.register(cellWithClass: HomeCell.self)
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    func setupConstraints() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func createSectionLayout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(105)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = spacing
        return section
    }
}
