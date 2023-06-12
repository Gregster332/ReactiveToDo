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

final class ListViewModel: Stepper {
    
    struct Input {
        let searchigKey: Driver<String>
        let flaggedOnly: Driver<Bool>
        let deleteItem: ControlEvent<IndexPath>
        let selectItem: ControlEvent<IndexPath>
        let createNewItem: ControlEvent<Void>
    }
    
    struct Output {
        let listItems: Observable<[ToDoSection]>
        let hideFlaggedButton: Observable<Bool>
    }

    // MARK: - Properties
    private let realmService: RealmService
    private let categoryType: ToDoCategories
    
    private var toDos = [ToDo]()
    private let searchigKey = BehaviorRelay<String>(value: "")
    private let flaggedOnly = BehaviorRelay<Bool>(value: false)
    private let listItems = BehaviorRelay<[ToDoSection]>(value: [])
    private let flagButtonHide = PublishSubject<Bool>()
    private(set) var steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialize
    init(
        realmService: RealmService,
        categoryType: ToDoCategories
    ) {
        self.realmService = realmService
        self.categoryType = categoryType
    }
    
    func transform(_ input: Input) -> Output {
        Observable.combineLatest(
            input.searchigKey.asObservable(),
            input.flaggedOnly.asObservable()
        ) { key, flagged in
            return (key, flagged)
        }
        .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
        .do(onNext: { [weak self] value in
            self?.searchigKey.accept(value.0)
            self?.flaggedOnly.accept(value.1)
        })
        .subscribe(onNext: { [weak self] value in
            self?.getAllTodos(value.0, flagged: value.1)
        })
        .disposed(by: disposeBag)
            
        
        input.deleteItem
            .bind { [weak self] indexPath in
                if let value = self?.searchigKey.value,
                   let flagged = self?.flaggedOnly.value {
                    self?.deleteItem(item: indexPath)
                    self?.getAllTodos(value, flagged: flagged)
                }
            }
            .disposed(by: disposeBag)
        
        input.selectItem
            .bind { [weak self] indexPath in
                self?.openToDo(item: indexPath)
            }
            .disposed(by: disposeBag)
        
        input.createNewItem
            .bind { [weak self] _ in
                self?.openToDo(item: nil)
            }
            .disposed(by: disposeBag)
        
        return Output(
            listItems: listItems.asObservable(),
            hideFlaggedButton: flagButtonHide.asObservable()
        )
    }
    
    private func deleteItem(item: IndexPath) {
        let todo = toDos[item.item]
        realmService.setItemCompleted(item: todo)
    }
    
    private func openToDo(item: IndexPath?) {
        if let item = item?.item {
            let toDo = toDos[item]
            steps.accept(AppStep.toDo(toDo))
        } else {
            steps.accept(AppStep.toDo(nil))
        }
    }
    
    private func getAllTodos(_ key: String = "", flagged: Bool = false) {
        realmService.getAllToDos()
            .catchAndReturn([])
            .map { [weak self] toDo in
                toDo.filter {
                    guard let self = self else { return true }
                    switch self.categoryType {
                    case .all:
                        return true
                    case .flagged:
                        return $0.flagged
                    case .todays:
                        return Calendar.current.isDateInToday($0.endDate)
                    case .scheduled:
                        return $0.endDate > Date()
                    }
                }
                .filter {
                    return !key.isEmpty ? $0.title.contains(key) || $0.subtitle.contains(key) : true
                }.filter {
                    return flagged ? $0.flagged : true
                }
            }
            .do(onNext: { [weak self] toDos in
                self?.toDos = toDos
            })
            .map { toDos in
                let cells = toDos.map {
                    ToDoSection.ToDoCell(
                        title: $0.title,
                        subtitle: $0.subtitle,
                        endDate: $0.endDate.toString(),
                        flagged: $0.flagged,
                        isExpiredSoon: $0.endDate > Date() && $0.endDate < Date().createDateAfter(with: 10))
                }
                return ToDoSection(items: cells)
            }
            .subscribe(onNext: { [weak self] section in
                self?.listItems.accept([section])
            })
            .disposed(by: disposeBag)
    }
    
    func emitFlagged() {
        flagButtonHide.onNext(categoryType == .flagged)
    }
}
