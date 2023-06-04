// 
//  HomePresenter.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/31/23.
//

import RxFlow
import RxCocoa
import RxSwift
import RealmSwift

protocol HomeViewModelProtocol: AnyObject {
    func selectItem(with index: IndexPath)
    func getAllCells()
    func representSections() -> Observable<[HomeSection]>
}

final class HomeViewModel: HomeViewModelProtocol, Stepper {
    
    private let realmService: RealmService
    private let sections = PublishRelay<[HomeSection]>()
    private let allObserver = PublishSubject<[ToDo]>()
    
    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Properties
    private weak var view: HomeViewControllerProtocol?

    // MARK: - Initialize
    init(view: HomeViewControllerProtocol, realmService: RealmService) {
        self.view = view
        self.realmService = realmService
        bind()
    }
    
    func selectItem(with index: IndexPath) {
        switch index.item {
        case 0:
            steps.accept(AppStep.main(.all))
        case 1:
            steps.accept(AppStep.main(.flagged))
        case 2:
            steps.accept(AppStep.main(.scheduled))
        default:
            steps.accept(AppStep.main(.todays))
        }
    }
    
    func representSections() -> Observable<[HomeSection]> {
        return sections.asObservable()
    }
    
    func getAllCells() {
        realmService
            .getAllTodosAsObserver()
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                self?.allObserver.onNext(items)
            })
            .disposed(by: disposeBag)
    }
}

private extension HomeViewModel {
    func bind() {
        allObserver.asObservable()
            .map {(
                $0.count,
                $0.filter { $0.flagged }.count,
                $0.filter { !Calendar.current.isDateInToday($0.endDate) }.count,
                $0.filter { Calendar.current.isDateInToday($0.endDate) }.count
            )}
            .map {
                return [HomeSection(items: [
                    HomeSection.Item(
                        name: "All",
                        image: UIImage(named: "checkmark-circle")!,
                        count: $0.0),
                    HomeSection.Item(
                        name: "Flagged",
                        image: UIImage(named: "flag_image")!,
                        count: $0.1),
                    HomeSection.Item(
                        name: "Scheduled",
                        image: UIImage(systemName: "calendar.badge.clock")!.withRenderingMode(.alwaysOriginal).withTintColor(.red),
                        count: $0.2),
                    HomeSection.Item(
                        name: "Today",
                        image: UIImage(systemName: "calendar.badge.exclamationmark")!.withRenderingMode(.alwaysOriginal).withTintColor(.black),
                        count: $0.3)
                ])]
            }
            .bind(to: sections)
            .disposed(by: disposeBag)
        
    }
}
