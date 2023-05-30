// 
//  ToDoBuilder.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import RxFlow

final class ToDoBuilder {
    
    static func build(
        realmService: RealmService,
        toDo: ToDo?
    ) -> (FlowContributor, UIViewController) {
        
        let view = ToDoViewController()
        let presenter = ToDoPresenter(
            view: view,
            realmService: realmService,
            toDo: toDo
        )
        
        view.presenter = presenter
        return (.contribute(withNextPresentable: view, withNextStepper: presenter), view)
    }
}
