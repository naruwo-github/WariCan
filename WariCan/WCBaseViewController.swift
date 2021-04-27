//
//  WCBaseViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/21.
//

import GoogleMobileAds
import RealmSwift

import UIKit

class WCBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    @IBOutlet private weak var eventTableView: UITableView!
    @IBOutlet private weak var startButton: WCCustomUIButton!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    // 全イベントデータ
    private var eventData: Results<Event>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 全イベントデータ取得
        self.eventData = WCRealmHelper.init().getAllEventData()
        
        self.setupAd()
        self.setupTableView()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    private func setupTableView() {
        self.eventTableView.register(UINib(resource: R.nib.wcEventCell), forCellReuseIdentifier: "EventCell")
    }
    
    @IBAction private func startButtonTapped(_ sender: Any) {
        let vc = R.storyboard.main.wcEventRegistrationViewController()!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! WCEventCell
        cell.setupEvent(event: self.eventData[indexPath.row].title)
        return cell
    }
    
    // イベントセルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.main.wcEventDetailViewController()!
        vc.setup(eventData: self.eventData[indexPath.row])
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // イベントデータの削除処理（セルの削除を経由）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            WCRealmHelper.init().delete(object: self.eventData[indexPath.row])
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
}
