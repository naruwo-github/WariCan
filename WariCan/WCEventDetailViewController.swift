//
//  WCEventDetailViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/06.
//

import UIKit
import GoogleMobileAds

class WCEventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var addPaymentButton: UIButton!
    @IBOutlet private weak var paymentTableView: UITableView!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.setupButtonLayout()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    private func setupButtonLayout() {
        self.addPaymentButton.layer.cornerRadius = 25
        self.addPaymentButton.layer.shadowColor = UIColor.black.cgColor
        self.addPaymentButton.layer.shadowRadius = 4.0
        self.addPaymentButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addPaymentButton.layer.shadowOpacity = 0.4
    }
    
    @IBAction private func addPaymentButtonTapped(_ sender: Any) {
        // TODO: 支払い追加モーダルの表示
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO:
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO:
        return UITableViewCell()
    }
    
}
