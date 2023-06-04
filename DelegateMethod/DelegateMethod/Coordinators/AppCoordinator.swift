//
//  AppCoordinator.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import RxFlow
import RxSwift
import RxCocoa

enum AppStep: Step {
    case home
    case main(ToDoCategories)
    case toDo(ToDo?)
    case dismiss
}

final class AppStepper: Stepper {

    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()

    var initialStep: Step {
        return AppStep.home
    }
}

final class AppFlow: Flow {
    
    private let dependencies: Dependencies
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.view.backgroundColor = .red
        viewController.setNavigationBarHidden(false, animated: false)
        return viewController
    }()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return FlowContributors.none }
        switch step {
        case .home:
            return home()
        case .main(let categoryType):
            return main(categoryType: categoryType)
        case .toDo(let todoObject):
            return toDo(toDo: todoObject)
        case .dismiss:
            rootViewController.popViewController(animated: true)
            return .none
        }
    }
    
    private func main(categoryType: ToDoCategories) -> FlowContributors {
        let main = ListBuilder.build(
            realmService: dependencies.realmService,
            categoryType: categoryType
        )
        self.rootViewController.pushViewController(main.1, animated: true)
        return .one(flowContributor: main.0)
    }
    
    private func toDo(toDo: ToDo?) -> FlowContributors {
        let todo = ToDoBuilder.build(
            realmService: dependencies.realmService,
            toDo: toDo
        )
        self.rootViewController.pushViewController(todo.1, animated: true)
        return .one(flowContributor: todo.0)
    }
    
    private func home() -> FlowContributors {
        let home = HomeBuilder.build(realmService: dependencies.realmService)
        self.rootViewController.setViewControllers([home.1], animated: true)
        return .one(flowContributor: home.0)
    }
}
