//
//  AddPaymentModalViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/11/04.
//

import GoogleMobileAds
import UIKit

class AddPaymentModalViewController: UIViewController, UITextFieldDelegate {
    
    // この値がnilでない場合は、既存の支払い履歴の更新処理をする
    private var updatedPayment: Payment?
    
    private var eventData: Event!
    private var payerCellIndex: Int!
    private var debtorCellIndexList: [Int]!
    private var refreshParentAction: (() -> Void)!
    private var showInterstitialAction: (() -> Void)!

    @IBOutlet private weak var topBannerAdView: GADBannerView!
    @IBOutlet private weak var bottomBannerAdView: GADBannerView!
    
    @IBOutlet private weak var debtorWarningLabel: UILabel!
    @IBOutlet private weak var payerTableView: UITableView! // tag=1
    @IBOutlet private weak var debtorTableView: UITableView! // tag=2
    @IBOutlet private weak var typeTextField: UITextField!
    @IBOutlet private weak var typeWarningLabel: UILabel!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var priceWarningLabel: UILabel!
    @IBOutlet private weak var addButton: WCCustomUIButton!
    @IBOutlet private weak var closeButton: WCCustomUIButton!
    
    public func setup(
        updatedPayment: Payment?,
        eventData: Event,
        payerCellIndex: Int,
        debtorCellIndexList: [Int],
        refreshParentAction: @escaping (() -> Void),
        showInterstitialAction: @escaping (() -> Void)
    ) {
        self.updatedPayment = updatedPayment
        self.eventData = eventData
        self.payerCellIndex = payerCellIndex
        self.debtorCellIndexList = debtorCellIndexList
        self.refreshParentAction = refreshParentAction
        self.showInterstitialAction = showInterstitialAction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.typeTextField, action: #selector(self.typeKeyboardCloseButtonTapped))
        self.typeTextField.delegate = self
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.priceTextField, action: #selector(self.priceKeyboardCloseButtonTapped))
        self.priceTextField.delegate = self
        self.priceTextField.keyboardType = .numberPad
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.setupTableViews()
        self.setupAd()
        self.setupUpdatedPayment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let diffHeight = keyboardSize.height - 150
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= diffHeight
        } else {
            let suggestionHeight = self.view.frame.origin.y + diffHeight
            self.view.frame.origin.y -= suggestionHeight
        }
    }
    
    @objc private func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func typeKeyboardCloseButtonTapped() {
        self.typeTextField.endEditing(true)
        self.typeTextField.resignFirstResponder()
    }
    
    @objc private func priceKeyboardCloseButtonTapped() {
        self.priceTextField.endEditing(true)
        self.priceTextField.resignFirstResponder()
    }
    
    private func setupUpdatedPayment() {
        guard let _updatedPayment = self.updatedPayment else {
            return
        }
        // 既存の支払い情報の降臨処理の場合
        // 支払い主
        self.payerCellIndex = self.eventData.payments.index(of: _updatedPayment)
        // 被支払い者たち
        // TODO: ここ指定するのは少々面倒
        // 何代かどうかを表すテキスト
        self.typeTextField.text = _updatedPayment.typeName
        // 金額を表す値
        self.priceTextField.text = Int(_updatedPayment.price).description
    }
    
    private func setupAd() {
        self.topBannerAdView.adUnitID = WCStringHelper.init().paymentModalTopBannerAdId
        self.topBannerAdView.rootViewController = self
        self.topBannerAdView.load(GADRequest())
        
        self.bottomBannerAdView.adUnitID = WCStringHelper.init().paymentModalBottomBannerAdId
        self.bottomBannerAdView.rootViewController = self
        self.bottomBannerAdView.load(GADRequest())
    }
    
    private func setupTableViews() {
        self.payerTableView.register(UINib(resource: R.nib.wcPayerCell), forCellReuseIdentifier: "PayerCell")
        self.debtorTableView.register(UINib(resource: R.nib.wcDebtorCell), forCellReuseIdentifier: "DebtorCell")
    }
    
    private func closeVC () {
        // キーボードを閉じる処理
        self.typeTextField.resignFirstResponder()
        self.priceTextField.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // 「追加」ボタン
    @IBAction private func addButtonTapped(_ sender: Any) {
        // typeとpriceが両方入っていて、
        // かつ「誰の？」が一人以上チェックされていれば、OK
        if !(self.typeTextField.text ?? "").isEmpty
            && !(self.priceTextField.text ?? "").isEmpty
            && self.debtorCellIndexList.count > 0 {
            
            // ***支払いデータを追加・保存する処理***
            let payment = Payment()
            payment.payerName = self.eventData.participants[self.payerCellIndex].name
            self.debtorCellIndexList.forEach({
                let debtor = Participant()
                debtor.name = self.eventData.participants[$0].name
                payment.debtor.append(debtor)
            })
            payment.typeName = self.typeTextField.text!
            payment.price = Double(self.priceTextField.text!)!
            
            if self.updatedPayment == nil {
                // 支払い情報新規作成処理
                WCRealmHelper.init().addPaymentToEvent(event: self.eventData, payment: payment)
            } else {
                // 支払い情報更新処理
                WCRealmHelper.init().updatePayment(event: self.eventData, updatedPayment: self.updatedPayment!, payment: payment)
            }
            // ********************************
            
            self.refreshParentAction()
            self.payerTableView.reloadData()
            self.debtorTableView.reloadData()
            // インタースティシャル広告を一定確率で表示
            self.showInterstitialAction()
            
            self.closeVC()
        }
        
        // 警告ラベルを表示させる処理
        if (self.typeTextField.text ?? "").isEmpty {
            self.typeWarningLabel.isHidden = false
        }
        if (self.priceTextField.text ?? "").isEmpty {
            self.priceWarningLabel.isHidden = false
        }
        if self.debtorCellIndexList.count == 0 {
            self.debtorWarningLabel.isHidden = false
        }
    }
    
    // 「戻る」ボタン
    @IBAction private func closeButtonTapped(_ sender: Any) {
        self.closeVC()
    }
    
    // 「何の代金？」フィールドをタップした時
    @IBAction private func typeFieldFocused(_ sender: Any) {
        self.typeWarningLabel.isHidden = true
    }
    
    // 「いくら？」フィールドをタップした時
    @IBAction private func priceFieldFocused(_ sender: Any) {
        self.priceWarningLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

// MARK: UITableView周りの設定のための拡張
extension AddPaymentModalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 1:                 // 「誰が？」のテーブルビュー
            return self.eventData.participants.count
        case 2:                 // 「誰の？」のテーブルビュー
            return self.eventData.participants.count
        default:
            fatalError()   // ここにはこない想定
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 1:                 // 「誰が？」のテーブルビュー
            self.payerCellIndex = indexPath.row
        case 2:                 // 「誰の？」のテーブルビュー
            if self.debtorCellIndexList.contains(indexPath.row) {
                self.debtorCellIndexList.removeAll(where: { $0 == indexPath.row })
            } else {
                self.debtorCellIndexList.append(indexPath.row)
            }
        default:
            fatalError()   // ここにはこない想定
        }
        
        self.refreshParentAction()
        self.payerTableView.reloadData()
        self.debtorTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 1:                 // 「誰が？」のテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayerCell") as! WCPayerCell
            cell.setupPayer(payer: self.eventData.participants[indexPath.row].name)
            // 支払い主ならチェックマークを表示
            if self.payerCellIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 2:                 // 「誰の？」のテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell") as! WCDebtorCell
            cell.setupDebtor(debtor: self.eventData.participants[indexPath.row].name)
            // 支払われている人ならチェックマークを表示
            if self.debtorCellIndexList.contains(indexPath.row) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        default:
            fatalError()   // ここにはこない想定
        }
    }
 
}
