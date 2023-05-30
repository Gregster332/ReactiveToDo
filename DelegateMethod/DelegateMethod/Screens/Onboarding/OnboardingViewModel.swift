//
//  OnboardingViewModel.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/19/23.
//

import RxCocoa
import RxSwift
import RxFlow

final class SettingsService {
    
    init() {
        UserDefaults.standard.set(false, forKey: "some")
    }
}

extension SettingsService: ReactiveCompatible {}

extension Reactive where Base: SettingsService {
    var isNeeded: Observable<Bool> {
        return UserDefaults.standard.rx
            .observe(Bool.self, "some")
            .compactMap { $0 }
    }
}
