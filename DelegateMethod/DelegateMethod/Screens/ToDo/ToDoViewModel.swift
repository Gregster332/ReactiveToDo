// 
//  ToDoPresenter.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import RxSwift
import RxCocoa
import RxFlow

protocol ToDoViewModelProtocol: AnyObject {
    func saveData()
    func representToDoHandler() -> BehaviorRelay<ToDo?>
    func representTitle() -> BehaviorSubject<String>
    func representDescription() -> BehaviorSubject<String>
    func representEndDate() -> BehaviorSubject<Date>
    func representFlagged() -> BehaviorSubject<Bool>
}

final class ToDoViewModel: ToDoViewModelProtocol, Stepper {
    let steps = PublishRelay<Step>()
    
    // MARK: - Properties
    private weak var view: ToDoViewControllerProtocol?
    private let realmService: RealmService
    
    private let toDoHandler: BehaviorRelay<ToDo?> = BehaviorRelay(value: nil)
    private let titleText = BehaviorSubject<String>(value: "")
    private let descriptionText = BehaviorSubject<String>(value: "")
    private let selectedEndDate = BehaviorSubject<Date>(value: Date())
    private let flagged = BehaviorSubject<Bool>(value: false)
    private let disposedBag = DisposeBag()
    private var isUpdate = false
    private var idBeforeUpdate: String = ""

    // MARK: - Initialize
    init(
        view: ToDoViewControllerProtocol,
        realmService: RealmService,
        toDo: ToDo?
    ) {
        self.view = view
        self.realmService = realmService
        
        isUpdate = toDo != nil
        idBeforeUpdate = toDo?._id.stringValue ?? ""
        
        applyInitialDataIfExcided(toDo: toDo)
        
        Observable.combineLatest(titleText, descriptionText, selectedEndDate, flagged) { title, desc, date, flagged in
            return (title, desc, date, flagged)
        }
        .map {
            if !$0.0.isEmpty && !$0.1.isEmpty && !($0.2 < Date()) {
                let toDo = ToDo(title: $0.0, subtitle: $0.1, endDate: $0.2, flagged: $0.3)
                return toDo
            } else {
                return nil
            }
        }
        .asObservable()
        .bind(to: toDoHandler)
        .disposed(by: disposedBag)
    }
    
    func saveData() {
        if let item = toDoHandler.value {
            if !isUpdate {
                realmService.addToDo(item: item)
            } else {
                realmService.updateItem(item: item, query: idBeforeUpdate)
            }
            steps.accept(AppStep.dismiss)
        }
    }
    
    func representTitle() -> BehaviorSubject<String> {
        return titleText
    }
    
    func representDescription() -> BehaviorSubject<String> {
        return descriptionText
    }
    
    func representEndDate() -> BehaviorSubject<Date> {
        return selectedEndDate
    }
    
    func representFlagged() -> BehaviorSubject<Bool> {
        return flagged
    }
    
    func representToDoHandler() -> BehaviorRelay<ToDo?> {
        return toDoHandler
    }
    
    private func applyInitialDataIfExcided(toDo: ToDo?) {
        if let toDo = toDo {
            titleText.onNext(toDo.title)
            descriptionText.onNext(toDo.subtitle)
            selectedEndDate.onNext(toDo.endDate)
            flagged.onNext(toDo.flagged)
        }
    }
}
