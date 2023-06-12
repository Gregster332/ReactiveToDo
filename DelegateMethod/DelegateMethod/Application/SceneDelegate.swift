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
    var rootViewController: UIViewController!
    
    lazy var deeplinkCoordinator: DeeplinkCoordinator = {
           return DeeplinkCoordinator(handlers: [
               SampleDeeplinkHandler(rootViewController: self.rootViewController)
           ])
       }()

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
                self.rootViewController = root
                window.makeKeyAndVisible()
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let first = URLContexts.first {
            deeplinkCoordinator.handleUrl(first.url)
        }
    }
}

protocol DeeplinkProtocol {
    func canOpenUrl(_ url: URL) -> Bool
    func openUrl(_ url: URL)
}

protocol DeeplinkHandler {
    
    @discardableResult
    func handleUrl(_ url: URL) -> Bool
}

final class DeeplinkCoordinator {
    
    let handlers: [DeeplinkProtocol]
    
    init(handlers: [DeeplinkProtocol]) {
        self.handlers = handlers
    }
}

extension DeeplinkCoordinator: DeeplinkHandler {
    
    @discardableResult
    func handleUrl(_ url: URL) -> Bool {
        guard let handler = handlers.first(where: { $0.canOpenUrl(url) }) else {
            return false
        }
        handler.openUrl(url)
        return true
    }
}

final class SampleDeeplinkHandler: DeeplinkProtocol {
    
    private weak var rootViewController: UIViewController?
    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    func canOpenUrl(_ url: URL) -> Bool {
        return url.absoluteString == "deeplink://test"
    }
    
    func openUrl(_ url: URL) {
        guard canOpenUrl(url) else { return }
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        rootViewController?.present(vc, animated: true)
    }
    
    
}

