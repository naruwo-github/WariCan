//
//  WCEventDetailViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/06.
//

import UIKit
import GoogleMobileAds
import RealmSwift

class WCEventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tripTitleLabel: UILabel!
    @IBOutlet private weak var addPaymentButton: UIButton!
    @IBOutlet private weak var paymentTableView: UITableView! // tag=0
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    // 支払い追加モーダル上の要素
    @IBOutlet private weak var paymentModalView: UIView!
    @IBOutlet private weak var debtorWarningLabel: UILabel!
    @IBOutlet private weak var payerTableView: UITableView! // tag=1
    @IBOutlet private weak var debtorTableView: UITableView! // tag=2
    @IBOutlet private weak var typeTextField: UITextField!
    @IBOutlet private weak var typeWarningLabel: UILabel!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var priceWarningLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    private var payerCellIndex: Int = 0 // 支払い主のセルのインデックス（この値は一つだけ）
    private var debtorCellIndexList: [Int] = [] // 払われた人のインデックスのリスト（初期値は空で）
    
    // イベントデータ　setup関数内部で初期化するため強制アンラップ
    private var eventData: Event!
    
    public func setup(eventData: Event) {
        self.eventData = eventData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripTitleLabel.text = self.eventData.title
        
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
    
    // TODO: IBDesignableで、WCCustomUIButtonクラス作る
    // ⇨コード量の大幅削減をしようか（他のクラス内でも使えるし）
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
        
        self.priceTextField.keyboardType = .numberPad
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
    
    private func refreshTableViews() {
        self.paymentTableView.reloadData()
        self.payerTableView.reloadData()
        self.debtorTableView.reloadData()
    }
    
    private func calculateWariCanResult() {
        // ***************************
        // ***************************
        // TODO: 割り勘結果の計算と表示処理
        // ***************************
        // ***************************
    }
    
    // 「支払いを追加」ボタン
    @IBAction private func addPaymentButtonTapped(_ sender: Any) {
        self.paymentModalView.isHidden = false
        
        self.typeTextField.text = ""
        self.priceTextField.text = ""
        self.typeWarningLabel.isHidden = true
        self.priceWarningLabel.isHidden = true
    }
    
    // 「追加」ボタン
    @IBAction private func addButtonTapped(_ sender: Any) {
        // 警告ラベルたちは非表示にする
        self.typeWarningLabel.isHidden = true
        self.priceWarningLabel.isHidden = true
        self.debtorWarningLabel.isHidden = true
        
        // typeとpriceが両方入っていて、
        // かつ「誰の？」が一人以上チェックされていれば、OK
        if !(self.typeTextField.text ?? "").isEmpty
            && !(self.priceTextField.text ?? "").isEmpty
            && self.debtorCellIndexList.count > 0 {
            self.paymentModalView.isHidden = true
            
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
            WCRealmHelper.init().addPaymentToEvent(event: self.eventData, payment: payment)
            // ********************************
            
            self.paymentTableView.reloadData()
        }
        
        // **以下、警告ラベルを表示させる処理**
        
        if (self.typeTextField.text ?? "").isEmpty {
            self.typeWarningLabel.isHidden = false
        }
        if (self.priceTextField.text ?? "").isEmpty {
            self.priceWarningLabel.isHidden = false
        }
        if self.debtorCellIndexList.count == 0 {
            self.debtorWarningLabel.isHidden = false
        }
        
        // キーボードを閉じる処理
        self.typeTextField.resignFirstResponder()
        self.priceTextField.resignFirstResponder()
    }
    
    // 「戻る」ボタン
    @IBAction private func closeButtonTapped(_ sender: Any) {
        self.typeTextField.resignFirstResponder()
        self.priceTextField.resignFirstResponder()
        
        self.paymentModalView.isHidden = true
    }
    
    // 「＊初期画面へ」ボタン
    @IBAction private func backToBaseButtonTapped(_ sender: Any) {
        let vc = R.storyboard.main.wcBaseViewController()!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // 「何の代金？」フィールド
    @IBAction func typeFieldFocused(_ sender: Any) {
        // テキストフィールドをタップした時
        self.typeWarningLabel.isHidden = true
    }
    
    // 「いくら？」フィールド
    @IBAction func priceFieldFocused(_ sender: Any) {
        // テキストフィールドをタップした時
        self.priceWarningLabel.isHidden = true
    }
    
    // テーブルビューのセルの個数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            return self.eventData.payments.count// self.paymentCount
        case 1:         // 「誰が？」のテーブルビュー
            return self.eventData.participants.count
        case 2:         // 「誰の？」のテーブルビュー
            return self.eventData.participants.count
        default:        // ここにはこない想定
            fatalError()
        }
    }
    
    // セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
        // TODO: 編集画面に遷移する
        print()
        case 1:         // 「誰が？」のテーブルビュー
            self.payerCellIndex = indexPath.row
        case 2:         // 「誰の？」のテーブルビュー
            if self.debtorCellIndexList.contains(indexPath.row) {
                self.debtorCellIndexList.removeAll(where: { $0 == indexPath.row })
            } else {
                self.debtorCellIndexList.append(indexPath.row)
            }
        default:        // ここにはこない想定
            fatalError()
        }
        
        self.refreshTableViews()
    }
    
    // セルの情報・レイアウト設定関数
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! WCPaymentCell
            let payment = self.eventData.payments[indexPath.row]
            let debtorText = payment.debtor.count.description + "人分"
            cell.setupPayment(payer: payment.payerName, type: payment.typeName, debtor: debtorText, price: Int(payment.price).description + "円")
            return cell
        case 1:         // 「誰が？」のテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayerCell") as! WCPayerCell
            cell.setupPayer(payer: self.eventData.participants[indexPath.row].name)
            // 支払い主ならチェックマークを表示
            if self.payerCellIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 2:         // 「誰の？」のテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "DebtorCell") as! WCDebtorCell
            cell.setupDebtor(debtor: self.eventData.participants[indexPath.row].name)
            // 支払われている人ならチェックマークを表示
            if self.debtorCellIndexList.contains(indexPath.row) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        default:        // ここにはこない想定
            fatalError()
        }
    }
    
    // TODO: 誰が、誰ののターブルビューでは、削除がうつらないようにしたい
    // 支払いセルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビューのみ削除処理が可能
            if editingStyle == UITableViewCell.EditingStyle.delete {
                WCRealmHelper.init().delete(object: self.eventData.payments[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            }
        case 1:         // 「誰が？」のテーブルビュー
            print()
        case 2:         // 「誰の？」のテーブルビュー
            print()
        default:        // ここにはこない想定
            fatalError()
        }
    }
    
    // 各セルの高さを設定する関数
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
