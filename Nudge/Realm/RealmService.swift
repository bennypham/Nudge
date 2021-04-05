//
//  RealmService.swift
//  Nudges
//
//  Created by Benny Pham on 2/18/21.
//

import Foundation
import RealmSwift

class RealmService {
    
    private init() {}
//    static let shared = RealmService()
    
    let realm = try! Realm()
    
    func createReminder<T: Object>(_ reminder: T) {
        do {
            try realm.write {
                realm.add(reminder)
            }
        } catch {
            print("Error trying to create")
        }
    }
    
    func updateReminder<T: Object>(_ reminder: T, with dictionary: [String: Any?]) {
        do {
            try realm.write{
                for (key, value) in dictionary {
                    reminder.setValue(value, forKey: key)
                }
            }
        } catch {
            print("Error trying to update")
        }
    }
    
    func deleteReminder<T: Object>(_ reminder: T) {
        do {
            try realm.write{
                realm.delete(reminder)
            }
        } catch {
            print("Error trying to delete")
        }
        
    }
}
