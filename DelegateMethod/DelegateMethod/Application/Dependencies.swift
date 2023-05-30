//
//  Dependencies.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import Foundation

extension SceneDelegate {
    func dependencies() -> Dependencies {
        
        let realmService = RealmServiceImpl()
        
        return Dependencies(realmService: realmService)
    }
}

struct Dependencies {
    let realmService: RealmService
}
