//
//  ToDoModel.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 6/4/23.
//

import RealmSwift

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
