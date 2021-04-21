//
//  WCRealmHelper.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/21.
//

import Foundation
import RealmSwift

final class WCRealmHelper {
    
    private let realm = try! Realm()
    
    init() {
    }
    
    func getAllEventData() -> Results<Event> {
        return self.realm.objects(Event.self)
    }
    
    func deleteAll() {
        do {
            try self.realm.write {
                self.realm.deleteAll()
            }
        } catch {
            print("Error in deleteAll...")
        }
    }
    
    func add(object: Object) {
        do {
            try self.realm.write({ () -> Void in
                self.realm.add(object)
            })
        } catch {
            print("Error in add...")
        }
    }
    
    func delete(object: Object) {
        do {
            try self.realm.write {
                self.realm.delete(object)
            }
        } catch {
            print("Error in delete...")
        }
    }
    
}
