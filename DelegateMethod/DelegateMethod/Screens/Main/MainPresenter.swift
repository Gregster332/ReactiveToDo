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

struct ToDoSection: SectionModelType {
    var items: [ToDo]
    
    init(original: ToDoSection, items: [ToDo]) {
        self = original
        self.items = items
    }
    
    init(items: [ToDo]) {
        self.items = items
    }
}

protocol MainPresenterProtocol: AnyObject {
    var searchigKey: BehaviorRelay<String> { get }
    var listItems: BehaviorRelay<[ToDoSection]> { get set }
    var flaggedOnly: BehaviorRelay<Bool> { get set }
    func deleteItem(item: IndexPath)
    func openToDo(toDo: ToDo?)
    func getAllTodos()
}

final class MainPresenter: MainPresenterProtocol, Stepper {
    
    // MARK: - Properties
    private weak var view: MainViewControllerProtocol?
    private let realmService: RealmService
    private var toDos: [ToDo] = []
    private(set) var searchigKey = BehaviorRelay(value: "")
    var listItems: BehaviorRelay<[ToDoSection]> = BehaviorRelay(value: [])
    var flaggedOnly: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    private(set) var steps = PublishRelay<Step>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialize
    init(
        view: MainViewControllerProtocol,
        realmService: RealmService
    ) {
        self.view = view
        self.realmService = realmService
    }
    
    func deleteItem(item: IndexPath) {
        let todo = toDos[item.item]
        realmService.setItemCompleted(item: todo)
            .subscribe(onNext: { [weak self] in
                self?.getAllTodos()
            })
            .disposed(by: disposeBag)
    }
    
    func openToDo(toDo: ToDo?) {
        steps.accept(AppStep.toDo(toDo))
    }
    
    func getAllTodos() {
        toDos = realmService.todoObservedObject()
        
        Observable.combineLatest(Observable.just(toDos), searchigKey.asObservable(), flaggedOnly.asObservable()) { toDos, key, flaggedOnly in
            
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
        .subscribe(onNext: { [weak self] filteredTodos in
            self?.listItems.accept([.init(items: filteredTodos)])
        })
        .disposed(by: disposeBag)
        
//        Observable.combineLatest(Observable.just(toDos), flaggedOnly.asObservable()) { toDos, flaggedOnly in
//            if !flaggedOnly {
//                return toDos
//            } else {
//                return toDos.filter { $0.flagged }
//            }
//        }
//        .subscribe(onNext: { [weak self] flaggedOnlyToDos in
//            self?.listItems.accept([.init(items: flaggedOnlyToDos)])
//        })
//        .disposed(by: disposeBag)
        
//        flaggedOnly
//            .asObservable()
//            .subscribe(onNext: { value in
//                print(value)
//            })
//            .disposed(by: disposeBag)
    }
}


// MARK: - Private Methods
private extension MainPresenter {
    
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
}
