//
//  DBTest.swift
//  WariCanTests
//
//  Created by Narumi Nogawa on 2021/09/05.
//

/*
 XCTestのライフサイクルの参考になりそうな記事：https://qiita.com/sunstripe2011/items/8102e79b4b3c71ab3508
 */

import XCTest
@testable import WariCan

class DBTest: XCTestCase {
    
    private let eventCount = WCRealmHelper.init().getAllEventData().count
    private let sampleTitle = "SampleEventABC"

    override func setUpWithError() throws {
        // イベントデータの作成
        let event = Event()
        event.title = self.sampleTitle
        // 参加者A,B,Cの追加
        let participantA = Participant()
        participantA.name = "A"
        event.participants.append(participantA)
        let participantB = Participant()
        participantB.name = "B"
        event.participants.append(participantB)
        let participantC = Participant()
        participantC.name = "C"
        event.participants.append(participantC)
        // データの保存
        WCRealmHelper.init().add(object: event)
    }

    override func tearDownWithError() throws {
        // 作成したイベントを取得して削除
        let eventABC = WCRealmHelper.init().getAllEventData().first(where: { $0.title == self.sampleTitle })!
        WCRealmHelper.init().delete(object: eventABC)
        XCTAssertEqual(self.eventCount, WCRealmHelper.init().getAllEventData().count)
    }
    
    func testAddEvent() throws {
        // データの追加は、setUpで行っている
        let eventCountAdded = WCRealmHelper.init().getAllEventData().count
        // イベントデータが保存できているかを確認するテスト
        XCTAssertEqual(self.eventCount + 1, eventCountAdded)
    }
    
    // TODO: 金額計算処理の切り出し後、テストを追記すべし
    func testCalculate() throws {
        XCTAssertEqual(1, 1)
    }

}
