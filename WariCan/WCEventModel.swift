//
//  WCEventModel.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/21.
//

import Foundation
import RealmSwift

// MARK: - <イベントのRealmオブジェクト>
class Event: Object {
    
//    @objc dynamic var id = 0                // 一意に割り振られるid
    @objc dynamic var title = ""            // イベントのタイトル
    
    let participants = List<Participant>()  // 全参加者のリスト
    let payments = List<Payment>()          // 全支払いのリスト
    
//    override static func primaryKey() -> String? {
//        return "id"
//    }
    
}
