//
//  WCBaseViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/21.
//

import GoogleMobileAds
import UIKit

class WCBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    @IBOutlet private weak var eventTableView: UITableView!
    @IBOutlet private weak var startButton: UIButton!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.setupTableView()
        self.setupButtonLayout()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
//        self.bottomBannerView.delegate = self
    }
    
    private func setupTableView() {
        // TODO: セルの登録などを行うべし
    }
    
    private func setupButtonLayout() {
        self.startButton.layer.cornerRadius = 25
        self.startButton.layer.shadowColor = UIColor.black.cgColor
        self.startButton.layer.shadowRadius = 4.0
        self.startButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.startButton.layer.shadowOpacity = 0.4
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Realmデータからイベント数を取得する
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Realmデータからイベントを取得し、セルを修正して返す
        return UITableViewCell()
    }
    
    //    /// Tells the delegate an ad request loaded an ad.
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//      print("adViewDidReceiveAd")
//    }
//
//    /// Tells the delegate an ad request failed.
//    func adView(_ bannerView: GADBannerView,
//        didFailToReceiveAdWithError error: GADRequestError) {
//      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
//    }
//
//    /// Tells the delegate that a full-screen view will be presented in response
//    /// to the user clicking on an ad.
//    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
//      print("adViewWillPresentScreen")
//    }
//
//    /// Tells the delegate that the full-screen view will be dismissed.
//    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
//      print("adViewWillDismissScreen")
//    }
//
//    /// Tells the delegate that the full-screen view has been dismissed.
//    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
//      print("adViewDidDismissScreen")
//    }
//
//    /// Tells the delegate that a user click will open another app (such as
//    /// the App Store), backgrounding the current app.
//    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
//      print("adViewWillLeaveApplication")
//    }
    
}

