// 
//  ToDoPresenter.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import RxSwift
import RxCocoa
import RxFlow

final class ToDoViewModel: Stepper {
    
    struct Input {
        let titleText: Driver<String>
        let descriptionText: Driver<String>
        let selectedEndDate: Driver<Date>
        let flagged: Driver<Bool>
        let saveButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let toDo: Observable<ToDo?>
    }
    
    let steps = PublishRelay<Step>()
    
    // MARK: - Properties
    private let realmService: RealmService
    
    private let toDoHandler: BehaviorRelay<ToDo?> = BehaviorRelay(value: nil)
    private let titleText = PublishSubject<String>()
    private let descriptionText = PublishSubject<String>()
    private let selectedEndDate = PublishSubject<Date>()
    private let flagged = PublishSubject<Bool>()
    private let disposedBag = DisposeBag()
    private var isUpdate = false
    private var idBeforeUpdate: String = ""

    // MARK: - Initialize
    init(
        realmService: RealmService,
        toDo: ToDo?
    ) {
        self.realmService = realmService
        
        isUpdate = toDo != nil
        idBeforeUpdate = toDo?._id.stringValue ?? ""
        
        Observable.combineLatest(titleText, descriptionText, selectedEndDate, flagged) { title, desc, date, flagged in
            return (title, desc, date, flagged)
        }
        .debounce(RxTimeInterval.microseconds(500), scheduler: MainScheduler.instance)
        .map { tuple -> ToDo? in
            if !tuple.0.isEmpty && !tuple.1.isEmpty && !(tuple.2 < Date()) {
                let toDo = ToDo(title: tuple.0, subtitle: tuple.1, endDate: tuple.2, flagged: tuple.3)
                return toDo
            } else {
                return nil
            }
        }
        .subscribe(onNext: { [weak self] toDo in
            self?.toDoHandler.accept(toDo)
        })
        .disposed(by: disposedBag)
        
        applyInitialDataIfExcided(toDo: toDo)
    }
    
    func transform(input: Input) -> Output {
        input.titleText
            .drive(onNext: { [weak self] text in
                self?.titleText.onNext(text)
            })
            .disposed(by: disposedBag)

        input.descriptionText
            .drive(onNext: { [weak self] text in
                self?.descriptionText.onNext(text)
            })
            .disposed(by: disposedBag)

        input.selectedEndDate
            .drive(onNext: { [weak self] date in
                self?.selectedEndDate.onNext(date)
            })
            .disposed(by: disposedBag)

        input.flagged
            .drive(onNext: { [weak self] flagged in
                self?.flagged.onNext(flagged)
            })
            .disposed(by: disposedBag)
        
        input.saveButtonTapped
            .bind { [weak self] _ in
                self?.saveData()
            }
            .disposed(by: disposedBag)
        
        return Output(toDo: toDoHandler.asObservable())
       
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
    
    private func applyInitialDataIfExcided(toDo: ToDo?) {
        if let toDo = toDo {
            titleText.onNext(toDo.title)
            descriptionText.onNext(toDo.subtitle)
            selectedEndDate.onNext(toDo.endDate)
            flagged.onNext(toDo.flagged)
        }
    }
}
