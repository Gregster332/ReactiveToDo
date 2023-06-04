//
//  RxExtensions.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 6/3/23.
//

import RxSwift
import RxCocoa

infix operator <->
func <-> <T>(property: ControlProperty<T>, variable: BehaviorSubject<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.onNext(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}
