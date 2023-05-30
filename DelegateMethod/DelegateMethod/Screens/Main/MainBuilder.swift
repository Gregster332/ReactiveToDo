// 
//  MainBuilder.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import RxFlow

final class MainBuilder {
    
    static func build(
        realmService: RealmService
    ) -> (FlowContributor, UIViewController) {
        
        let view = MainViewController()
        let presenter = MainPresenter(
            view: view,
            realmService: realmService)
        
        view.presenter = presenter
        return (.contribute(withNextPresentable: view, withNextStepper: presenter), view)
    }
}
