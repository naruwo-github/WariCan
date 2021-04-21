//
//  WCParticipantModel.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/21.
//

import Foundation
import RealmSwift

// MARK: - <参加者のRealmオブジェクト>
class Participant: Object {
    
    @objc dynamic var id: Int = 0       // 一意に割り振られるid
    @objc dynamic var name: String = "" // 参加者の名前
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
