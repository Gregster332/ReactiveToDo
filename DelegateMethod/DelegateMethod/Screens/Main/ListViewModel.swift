// 
//  MainPresenter.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import RxSwift
import RxCocoa
import RxFlow
import RxDataSources

enum ToDoCategories: String {
    case all
    case flagged
    case todays
    case scheduled
}

struct ToDoSection: SectionModelType {
    var items: [ToDoCell]
    
    init(original: ToDoSection, items: [ToDoCell]) {
        self = original
        self.items = items
    }
    
    init(items: [ToDoCell]) {
        self.items = items
    }
    
    struct ToDoCell {
        let title: String
        let subtitle: String
        let endDate: String
        let flagged: Bool
        let isExpiredSoon: Bool
    }
}

protocol ListViewModelProtocol: AnyObject {
    func deleteItem(item: IndexPath)
    func openToDo(item: IndexPath?)
    func getAllTodos()
    func representSearchigKey() -> BehaviorRelay<String>
    func representListItems() -> BehaviorRelay<[ToDoSection]>
    func representFlaggedOnly() -> BehaviorRelay<Bool>
    func representFlagButtonHide() -> BehaviorRelay<Bool>
}

final class ListViewModel: ListViewModelProtocol, Stepper {

    // MARK: - Properties
    private weak var view: ListViewControllerProtocol?
    private let realmService: RealmService
    private let categoryType: ToDoCategories
    
    private let toDos = BehaviorRelay<[ToDo]>(value: [])
    private let searchigKey = BehaviorRelay(value: "")
    private let listItems = BehaviorRelay<[ToDoSection]>(value: [])
    private let flaggedOnly = BehaviorRelay(value: false)
    private let flagButtonHide = BehaviorRelay<Bool>(value: false)
    private(set) var steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialize
    init(
        view: ListViewControllerProtocol,
        realmService: RealmService,
        categoryType: ToDoCategories
    ) {
        self.view = view
        self.realmService = realmService
        self.categoryType = categoryType
        
        Observable.combineLatest(toDos, searchigKey.asObservable(), flaggedOnly.asObservable()) { toDos, key, flaggedOnly -> [ToDo] in
            
            if flaggedOnly && !key.isEmpty {
                return toDos.filter({
                    ($0.title.lowercased().contains(key.lowercased()) ||
                     $0.subtitle.lowercased().contains(key.lowercased())) && $0.flagged == flaggedOnly
                })
            }
            
            if flaggedOnly {
                return toDos.filter { $0.flagged == flaggedOnly }
            }
            
            if key.isEmpty || key == "" {
                return toDos
            } else {
                return toDos.filter({
                    $0.title.lowercased().contains(key.lowercased()) ||
                    $0.subtitle.lowercased().contains(key.lowercased())
                })
            }
        }
        .map {
            $0.map {
                return ToDoSection.ToDoCell(
                    title: $0.title,
                    subtitle: $0.subtitle,
                    endDate: $0.endDate.toString(),
                    flagged: $0.flagged,
                    isExpiredSoon: $0.endDate > Date() && $0.endDate < Date().createDateAfter(with: 10))
            }
        }
        .subscribe(onNext: { [weak self] filteredTodos in
            self?.listItems.accept([.init(items: filteredTodos)])
        })
        .disposed(by: disposeBag)
        
        toDos.asObservable()
            .map { $0.count }
            .subscribe { [weak self] count in
                guard let self = self else {
                    self?.flagButtonHide.accept(false)
                    return
                }
                self.flagButtonHide.accept(categoryType == .flagged)
            }
            .disposed(by: disposeBag)
    }
    
    func representSearchigKey() -> BehaviorRelay<String> {
        searchigKey
    }
    
    func representListItems() -> BehaviorRelay<[ToDoSection]> {
        listItems
    }
    func representFlaggedOnly() -> BehaviorRelay<Bool> {
        flaggedOnly
    }
    
    func representFlagButtonHide() -> BehaviorRelay<Bool> {
        flagButtonHide
    }
    
    func deleteItem(item: IndexPath) {
        let todo = toDos.value[item.item]
        realmService.setItemCompleted(item: todo)
            .subscribe(onNext: { [weak self] in
                self?.getAllTodos()
            })
            .disposed(by: disposeBag)
    }
    
    func openToDo(item: IndexPath?) {
        if let item = item?.item {
            let toDo = toDos.value[item]
            steps.accept(AppStep.toDo(toDo))
        } else {
            steps.accept(AppStep.toDo(nil))
        }
    }
    
    func getAllTodos() {
        realmService.getAllTodosAsObserver()
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self = self else {
                    return
                }
                switch self.categoryType {
                case .all:
                    self.toDos.accept(items)
                case .flagged:
                    self.toDos.accept(items.filter { $0.flagged })
                case .todays:
                    self.toDos.accept(items.filter { Calendar.current.isDateInToday($0.endDate) })
                case .scheduled:
                    self.toDos.accept(items.filter { $0.endDate > Date() })
                }
            })
            .disposed(by: disposeBag)
    }
}
