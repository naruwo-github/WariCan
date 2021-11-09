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
            try self.realm.write { [unowned self] in
                self.realm.deleteAll()
            }
        } catch {
            // logを計測してもいいねここで
            print("Error in deleteAll...")
        }
    }
    
    // 新規オブジェクトの追加
    func add(object: Object) {
        do {
            try self.realm.write { [unowned self] in
                self.realm.add(object)
            }
        } catch {
            // logを計測してもいいねここで
            print("Error in add...")
        }
    }
    
    func delete(object: Object) {
        do {
            try self.realm.write { [unowned self] in
                self.realm.delete(object)
            }
        } catch {
            // logを計測してもいいねここで
            print("Error in delete...")
        }
    }
    
    // 既存イベントの支払い情報の更新
    func addPaymentToEvent(event: Event, payment: Payment) {
        do {
            try self.realm.write {
                event.payments.append(payment)
            }
        } catch {
            // logを計測してもいいねここで
            print("Error in add...")
        }
    }
    
    // 既存イベントのある支払い情報の更新
    func updatePayment(event: Event, updatedPayment: Payment, payment: Payment) {
        self.delete(object: updatedPayment)
        self.addPaymentToEvent(event: event, payment: payment)
    }
    
}
