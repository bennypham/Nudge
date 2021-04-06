//
//  Nudge.swift
//  Nudges
//
//  Created by Benny Pham on 11/10/20.
//

import UIKit
import RealmSwift

class Nudge: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(title: String, body: String, date: Date, _id: String) {
        self.init()
        self.title = title
        self.body = body
        self.date = date
    }
    
//    static func == (lhs: Nudge, rhs: Nudge) -> Bool {
//        return lhs._id == rhs._id && lhs.title == rhs.title && lhs.body == rhs.body && lhs.date == rhs.date
//    }
    
}
