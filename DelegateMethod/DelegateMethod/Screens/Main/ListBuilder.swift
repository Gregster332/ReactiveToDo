// 
//  MainBuilder.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import RxFlow

final class ListBuilder {
    
    static func build(
        realmService: RealmService,
        categoryType: ToDoCategories
    ) -> (FlowContributor, UIViewController) {
        
        let view = ListViewController(categoryType: categoryType)
        let viewModel = ListViewModel(
            view: view,
            realmService: realmService,
            categoryType: categoryType)
        
        view.viewModel = viewModel
        return (.contribute(withNextPresentable: view, withNextStepper: viewModel), view)
    }
}
