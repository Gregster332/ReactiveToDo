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

class ToDo: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title = ""
    @Persisted var subtitle = ""
    @Persisted var endDate = Date()
    @Persisted var flagged = false
    
    convenience init(title: String = "", subtitle: String = "", endDate: Date = Date(), flagged: Bool = false) {
        self.init()
        self.title = title
        self.subtitle = subtitle
        self.endDate = endDate
        self.flagged = flagged
    }
}

protocol RealmService {
    func addToDo(item: ToDo)
    func setItemCompleted(item: ToDo) -> Observable<Void>
    func updateItem(item: ToDo, query: String)
    func getAllTodosAsObserver() -> Single<[ToDo]>
}

final class RealmServiceImpl: RealmService {
    
    func addToDo(item: ToDo) {
        let realm = try! Realm()
        
        try! realm.write({
            realm.add(item)
        })
    }
    
    func setItemCompleted(item: ToDo) -> Observable<Void> {
        let realm = try! Realm()
        
        try! realm.write({
            realm.delete(item)
        })
        
        return Observable.create { obs in
            obs.onNext(())
            return Disposables.create()
        }
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
}
