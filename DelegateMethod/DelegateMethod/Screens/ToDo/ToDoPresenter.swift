// 
//  ToDoPresenter.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import RxSwift
import RxCocoa
import RxFlow

protocol ToDoPresenterProtocol: AnyObject {
    var titleText: BehaviorSubject<String> { get set }
    var descriptionText: BehaviorSubject<String> { get set }
    var selectedEndDate: BehaviorSubject<Date> { get set }
    var toDoHandler: BehaviorRelay<ToDo?> { get set }
    var flagged: BehaviorSubject<Bool> { get set }
    func saveData()
}

final class ToDoPresenter: ToDoPresenterProtocol, Stepper {
    let steps = PublishRelay<Step>()
    
    // MARK: - Properties
    private weak var view: ToDoViewControllerProtocol?
    private let realmService: RealmService
    
    var titleText = BehaviorSubject<String>(value: "")
    var descriptionText = BehaviorSubject<String>(value: "")
    var selectedEndDate = BehaviorSubject<Date>(value: Date())
    var toDoHandler: BehaviorRelay<ToDo?> = BehaviorRelay(value: nil)
    var flagged = BehaviorSubject<Bool>(value: false)
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
            if !$0.0.isEmpty && !$0.1.isEmpty && $0.2 > Date() {
                let toDo = ToDo()
                toDo.title = $0.0
                toDo.subtitle = $0.1
                toDo.endDate = $0.2
                toDo.flagged = $0.3
                return toDo
            } else {
                return nil
            }
        }
        .asObservable()
        .bind(to: toDoHandler)
        .disposed(by: disposedBag)
        
//        toDoHandler
//            .bind(onNext: { [weak self] _ in
//                self?.applyInitialDataIfExcided()
//            })
//            .disposed(by: disposedBag)
    }
    
    deinit {
        print("dsdsdsds")
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
    
    func applyInitialDataIfExcided(toDo: ToDo?) {
        if let toDo = toDo {
            titleText.onNext(toDo.title)
            descriptionText.onNext(toDo.subtitle)
            selectedEndDate.onNext(toDo.endDate)
            flagged.onNext(toDo.flagged)
        }
    }
}

// MARK: - Private Methods
private extension ToDoPresenter {
    
   
}
