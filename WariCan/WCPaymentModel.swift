//
//  WCPaymentModel.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/21.
//

import Foundation
import RealmSwift

// MARK: - <支払いのRealmオブジェクト>
class Payment: Object {
    
//    @objc dynamic var id: Int = 0               // 一意に割り振られるid
    @objc dynamic var payerName: String = ""    // 支払い者の名前
    @objc dynamic var price: Double = 0.0       // 支払いの金額
    
    let debtor = List<Participant>()            // 支払われた参加者のリスト
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
    
}
