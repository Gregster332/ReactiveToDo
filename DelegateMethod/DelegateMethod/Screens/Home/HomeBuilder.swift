// 
//  HomeBuilder.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/31/23.
//

import RxFlow

final class HomeBuilder {
    
    static func build(realmService: RealmService) -> (FlowContributor, UIViewController) {
        let view = HomeViewController()
        let viewModel = HomeViewModel(
            view: view,
            realmService: realmService
        )
        
        view.viewModel = viewModel
        return (.contribute(withNextPresentable: view, withNextStepper: viewModel), view)
    }
}
