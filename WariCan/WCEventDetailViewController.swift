//
//  WCEventDetailViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/06.
//

import UIKit
import GoogleMobileAds

class WCEventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var tripTitle: String?
    @IBOutlet private weak var tripTitleLabel: UILabel!
    @IBOutlet private weak var addPaymentButton: UIButton!
    @IBOutlet private weak var paymentTableView: UITableView! // tag=0
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    // 支払い追加モーダル上の要素
    @IBOutlet private weak var paymentModalView: UIView!
    @IBOutlet private weak var payerTableView: UITableView! // tag=1
    @IBOutlet private weak var debtorTableView: UITableView! // tag=2
    @IBOutlet private weak var typeTextField: UITextField!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripTitleLabel.text = self.tripTitle
        
        self.setupAd()
        self.setupButtonLayout()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    private func setupButtonLayout() {
        // 「支払いを追加」ボタン
        self.addPaymentButton.layer.cornerRadius = 25
        self.addPaymentButton.layer.shadowColor = UIColor.black.cgColor
        self.addPaymentButton.layer.shadowRadius = 4.0
        self.addPaymentButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addPaymentButton.layer.shadowOpacity = 0.4
        
        // 「追加」ボタン
        self.addButton.layer.cornerRadius = 25
        self.addButton.layer.shadowColor = UIColor.black.cgColor
        self.addButton.layer.shadowRadius = 4.0
        self.addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addButton.layer.shadowOpacity = 0.4
    }
    
    @IBAction private func addPaymentButtonTapped(_ sender: Any) {
        self.paymentModalView.isHidden = false
    }
    
    @IBAction private func addButtonTapped(_ sender: Any) {
        self.paymentModalView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            print()
        case 1:         // 「誰が？」のテーブルビュー
            print()
        case 2:         // 「誰の？」のテーブルビュー
            print()
        default:        // ここにはこない想定
            fatalError()
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            print()
        case 1:         // 「誰が？」のテーブルビュー
            print()
        case 2:         // 「誰の？」のテーブルビュー
            print()
        default:        // ここにはこない想定
            fatalError()
        }
        
        return UITableViewCell()
    }
    
}
