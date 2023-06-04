//
//  SceneDelegate.swift
//  DelegateMethod
//
//  Created by Grigory Zenkov on 20.02.2022.
//

import UIKit
import RxFlow
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let disposeBag = DisposeBag()
    var window: UIWindow?
    var flow: Flow?
    var coordinator = FlowCoordinator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        let dependencies = dependencies()
        flow = AppFlow(dependencies: dependencies)
        if let flow = flow {
            coordinator.coordinate(flow: flow, with: AppStepper.init())
            
            let window = UIWindow(windowScene: windowScene)
            self.window = window

            Flows.use(flow, when: .created) { root in
                window.rootViewController = root
                window.makeKeyAndVisible()
            }
        }
    }
}

