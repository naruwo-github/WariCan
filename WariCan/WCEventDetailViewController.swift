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
    @IBOutlet private weak var closeButton: UIButton!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripTitleLabel.text = self.tripTitle
        
        self.setupAd()
        self.setupButtonLayout()
        self.setupTextFieldKeyboard()
        self.setupTableViews()
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
        
        // 「もどる」ボタン
        self.closeButton.layer.cornerRadius = 20
        self.closeButton.layer.shadowColor = UIColor.black.cgColor
        self.closeButton.layer.shadowRadius = 4.0
        self.closeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.closeButton.layer.shadowOpacity = 0.4
    }
    
    private func setupTextFieldKeyboard() {
        // イベント名入力のキーボードに対して
        let typeToolbar = UIToolbar()
        typeToolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let typeSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self.typeTextField, action: nil)
        let typeKeyboardCloseButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.typeKeyboardCloseButtonTapped))
        typeToolbar.items = [typeSpacer, typeKeyboardCloseButton]
        self.typeTextField.inputAccessoryView = typeToolbar
        
        // 人名入力のキーボードに対して
        let priceToolbar = UIToolbar()
        priceToolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let priceSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self.priceTextField, action: nil)
        let priceKeyboardCloseButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.priceKeyboardCloseButtonTapped))
        priceToolbar.items = [priceSpacer, priceKeyboardCloseButton]
        self.priceTextField.inputAccessoryView = priceToolbar
    }
    
    @objc private func typeKeyboardCloseButtonTapped() {
        self.typeTextField.endEditing(true)
        self.typeTextField.resignFirstResponder()
    }
    
    @objc private func priceKeyboardCloseButtonTapped() {
        self.priceTextField.endEditing(true)
        self.priceTextField.resignFirstResponder()
    }
    
    private func setupTableViews() {
        self.paymentTableView.register(UINib(resource: R.nib.wcPaymentCell), forCellReuseIdentifier: "PaymentCell")
        self.payerTableView.register(UINib(resource: R.nib.wcPayerCell), forCellReuseIdentifier: "PayerCell")
        self.debtorTableView.register(UINib(resource: R.nib.wcDebtorCell), forCellReuseIdentifier: "DebtorCell")
    }
    
    @IBAction private func addPaymentButtonTapped(_ sender: Any) {
        self.paymentModalView.isHidden = false
    }
    
    @IBAction private func addButtonTapped(_ sender: Any) {
        self.paymentModalView.isHidden = true
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        self.paymentModalView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            return 1
        case 1:         // 「誰が？」のテーブルビュー
            return 2
        case 2:         // 「誰の？」のテーブルビュー
            return 3
        default:        // ここにはこない想定
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! WCPaymentCell
            return cell
        case 1:         // 「誰が？」のテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayerCell") as! WCPayerCell
            return cell
        case 2:         // 「誰の？」のテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell") as! WCDebtorCell
            return cell
        default:        // ここにはこない想定
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            return 80
        case 1:         // 「誰が？」のテーブルビュー
            return 50
        case 2:         // 「誰の？」のテーブルビュー
            return 50
        default:        // ここにはこない想定
            fatalError()
        }
    }
    
}
