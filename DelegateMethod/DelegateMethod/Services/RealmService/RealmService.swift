//
//  RealmService.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import RealmSwift
import RxRealm
import RxSwift
import RxDataSources

protocol RealmService {
    func addToDo(item: ToDo)
    func setItemCompleted(item: ToDo)
    func updateItem(item: ToDo, query: String)
    func getAllTodosAsObserver() -> Single<[ToDo]>
    func getAllToDos() -> Observable<[ToDo]>
}

final class RealmServiceImpl: RealmService {
    
    func addToDo(item: ToDo) {
        let realm = try! Realm()
        
        try! realm.write({
            realm.add(item)
        })
    }
    
    func setItemCompleted(item: ToDo) {
        let realm = try! Realm()
        
        try! realm.write({
            realm.delete(item)
        })
    }
    
    func updateItem(item: ToDo, query: String) {
        let realm = try! Realm()
        let object = realm.objects(ToDo.self).filter{ $0._id.stringValue == query }.first
        if let object = object {
            try! realm.write {
                object.title = item.title
                object.subtitle = item.subtitle
                object.endDate = item.endDate
                object.flagged = item.flagged
            }
        }
    }
    
    func getAllTodosAsObserver() -> Single<[ToDo]> {
        let realm = try! Realm()
        let results = realm.objects(ToDo.self).toArray()
        return Single.create { obs in
            let maybeError = RxError.unknown
            
            if !results.isEmpty {
                obs(.success(results))
            } else {
                obs(.failure(maybeError))
            }
            
            return Disposables.create()
        }
    }
    
    func getAllToDos() -> Observable<[ToDo]> {
        return Observable.create { obs in
            do {
                let realm = try Realm()
                obs.onNext(realm.objects(ToDo.self).toArray())
            } catch {
                obs.onError(error)
            }
            
            return Disposables.create()
        }
    }
}
