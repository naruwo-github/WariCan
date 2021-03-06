//
//  WCEventDetailViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/06.
//

import UIKit
import GoogleMobileAds
import RealmSwift

// *** WariCan結果算出アイデア ***
// ①：全員の出費を算出（払い過ぎは正、払わな過ぎは負）
// ②：降順でソート（出費過多が先頭に）
// ③：リストの最後（最大債務者, 出費=L）がリストの最初（最大債権者, F）に min(F, |L|) を支払ってバランスを再計算
// ④：全員のバランスが 0 になるまで ②-③ を繰り返す
// ***************************

// MARK: イベント詳細画面のVC
class WCEventDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var tripTitleLabel: UILabel!
    @IBOutlet private weak var addPaymentButton: WCCustomUIButton!
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
    @IBOutlet private weak var addButton: WCCustomUIButton!
    @IBOutlet private weak var closeButton: WCCustomUIButton!
    
    private var interstitial: GADInterstitialAd?
    private var payerCellIndex: Int = 0 // 支払い主のセルのインデックス（この値は一つだけ）
    private var debtorCellIndexList: [Int] = [] // 払われた人のインデックスのリスト（初期値は空で）
    private var eventData: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripTitleLabel.text = self.eventData.title
        self.setupAd()
        
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.typeTextField, action: #selector(self.typeKeyboardCloseButtonTapped))
        self.typeTextField.delegate = self
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.priceTextField, action: #selector(self.priceKeyboardCloseButtonTapped))
        self.priceTextField.delegate = self
        self.priceTextField.keyboardType = .numberPad
        
        self.setupTableViews()
        self.setWariCanResultText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    public func setup(eventData: Event) {
        self.eventData = eventData
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
        self.setWariCanResultText()
    }
    
    // TODO: 関数内が長くなるので、後で切り出しする
    // TODO: 計算周りのテストができないので、引数と戻り値を持った関数に切り出す
    private func setWariCanResultText() {
        // ①：全員の出費を算出（払い過ぎは正、払わな過ぎは負）し格納する
        // ["太郎": 6600, "二郎": -1500, "三郎": 1900, ...]の形式
        var balanceDict: [String: Double] = [:]
        self.eventData.participants.forEach({
            balanceDict.updateValue(0.0, forKey: $0.name)
        })
        
        self.eventData.payments.forEach({
            let payer = $0.payerName
            let price = $0.price
            var debtorsList: [String] = []
            for debtor in $0.debtor {
                debtorsList.append(debtor.name)
            }
            
            let pricePerPerson = price / Double(debtorsList.count) // 一人分の値段
            var diff = 1 // 損益調整用の変数
            if !debtorsList.contains(payer) {
                // 支払い者が自分の分を払わず他の人の分のみを払っている場合
                diff = 0
            }
            // 支払い者には、多く払った額を加算する
            balanceDict[payer]! += pricePerPerson * Double(debtorsList.count - diff)
            debtorsList.forEach({
                if $0 == payer {
                    // 支払った人からは引かない
                } else {
                    // 支払われ者には、一人分の値段を減算する
                    balanceDict[$0]! -= pricePerPerson
                }
            })
        })
        
        // 出力用の箱
        var resultData: [String: Double] = [:] // ["AtoB": 600, "AtoC": 300, "DtoB": 150]
        // ②：降順でソート（出費過多が先頭に）
        // 出費過多で降順にソートしたバランスシート
        var sortedBalanceDict = balanceDict.sorted { $0.value > $1.value }
        // ④：全員のバランスが 0 になるまで ②-③ を繰り返す
        while true {
            // ②：降順でソート（出費過多が先頭に）
            sortedBalanceDict = sortedBalanceDict.sorted { $0.value > $1.value }
            let paidTooMuch = sortedBalanceDict.first!.value
            let paidLess = sortedBalanceDict.last!.value
            
            if (paidTooMuch == 0 || paidLess == 0)
                || (paidTooMuch < 1 && abs(paidLess) < 1) {
                // 過払い額または過不足額が0になれば、割り勘計算が終了するためbreak
                // 小数点以下の計算によっては完全に0にならない場合があるため < 1 という条件も入れておく
                break
            }
            
            // ③：リストの最後（最大債務者, 出費=L）がリストの最初（最大債権者, F）に min(F, |L|) を支払ってバランスを再計算
            let refund = min(paidTooMuch, abs(paidLess))
            let tooMuchPayer = sortedBalanceDict.first!.key
            let lessPayer = sortedBalanceDict.last!.key
            let key = lessPayer + "to" + tooMuchPayer
            if resultData.keys.contains(key) {
                // 更新処理
                resultData.updateValue(resultData[key]! + refund, forKey: key)
            } else {
                // 新規登録処理
                resultData.updateValue(refund, forKey: key)
            }
            // 値の更新
            sortedBalanceDict[0].value = paidTooMuch - refund
            sortedBalanceDict[sortedBalanceDict.count - 1].value = paidLess + refund
            
        }
        
        self.setResultLabelText(resultData: resultData)
    }
    
    // 割り勘の計算データを受け取り、結果ラベルを設定する関数　金額はIntで丸めている
    private func setResultLabelText(resultData: [String: Double]) {
        if resultData.count > 0 {
            let sortedResultData = resultData.sorted { $0.value < $1.value } // 支払額の昇順でソート
            let valuesList = sortedResultData.map { $0.value } // 金額だけのリスト
            let longestDigitCount = Int(valuesList.max()!).description.count // 一番大きい金額の文字数
            var resultText = ""
            for i in sortedResultData {
                // TODO: 1, 10, 100円単位で丸める操作を選べるようにすべし！
                let keyElements = i.key.components(separatedBy: "to")
                var priceString = Int(i.value).description
                for _ in 0..<(longestDigitCount - priceString.count) {
                    priceString = "  " + priceString
                }
                resultText += keyElements.first! + " ⇨ " + keyElements.last! + " " + priceString + "円" + "\n"
            }
            self.resultLabel.text = resultText
        } else {
            self.resultLabel.text = "支払いを入力すると、\n二郎 ⇨ 太郎 1500円\n三郎 ⇨ 太郎   960円\nのように結果を表示します！"
        }
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
            
            self.refreshTableViews()
            // インタースティシャル広告を一定確率で表示
            self.showInterstitialAd()
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
    
    // 「何の代金？」フィールドをタップした時
    @IBAction func typeFieldFocused(_ sender: Any) {
        self.typeWarningLabel.isHidden = true
    }
    
    // 「いくら？」フィールドをタップした時
    @IBAction func priceFieldFocused(_ sender: Any) {
        self.priceWarningLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

// MARK: 広告関連のコードを管理するための拡張
extension WCEventDetailViewController {
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = WCStringHelper.init().eventDetailVCBottomBannerAdId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
        
        GADInterstitialAd.load(withAdUnitID: WCStringHelper.init().eventDetailVCInterstitialAdId,
                               request: GADRequest(),
                               completionHandler: { [unowned self] ad, error in
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                               })
    }
    
    private func showInterstitialAd() {
        let counter = UserDefaults.standard.integer(forKey: WCStringHelper.init().interstitialCounterKey)
        if counter == 5 {
            UserDefaults.standard.set(0, forKey: WCStringHelper.init().interstitialCounterKey)
            if self.interstitial != nil {
                self.interstitial!.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        } else {
            UserDefaults.standard.set(counter + 1, forKey: WCStringHelper.init().interstitialCounterKey)
        }
    }
    
}

// MARK: UITableView周りの設定のための拡張
extension WCEventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:                 // 支払いのテーブルビュー
            return self.eventData.payments.count// self.paymentCount
        case 1:                 // 「誰が？」のテーブルビュー
            return self.eventData.participants.count
        case 2:                 // 「誰の？」のテーブルビュー
            return self.eventData.participants.count
        default: fatalError()   // ここにはこない想定
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:                 // 支払いのテーブルビュー
        // TODO: 編集画面に遷移する
        print()
        case 1:                 // 「誰が？」のテーブルビュー
            self.payerCellIndex = indexPath.row
        case 2:                 // 「誰の？」のテーブルビュー
            if self.debtorCellIndexList.contains(indexPath.row) {
                self.debtorCellIndexList.removeAll(where: { $0 == indexPath.row })
            } else {
                self.debtorCellIndexList.append(indexPath.row)
            }
        default: fatalError()   // ここにはこない想定
        }
        
        self.refreshTableViews()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:                 // 支払いのテーブルビュー
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! WCPaymentCell
            let payment = self.eventData.payments[indexPath.row]
            cell.setupPayment(payer: payment.payerName, debtorCount: payment.debtor.count.description, type: payment.typeName, price: Int(payment.price).description)
            return cell
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
        default: fatalError()   // ここにはこない想定
        }
    }
    
    // TODO: 誰が、誰ののターブルビューでは、削除がうつらないようにしたい
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:         // 支払いのテーブルビューのみ削除処理が可能
            if editingStyle == UITableViewCell.EditingStyle.delete {
                WCRealmHelper.init().delete(object: self.eventData.payments[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            }
        case 1, 2: print("削除はしない")      // 「誰が？」&「誰の？」のテーブルビュー
        default: fatalError()   // ここにはこない想定
        }
        self.refreshTableViews()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0: return 70       // 支払いのテーブルビュー
        case 1, 2: return 50       // 「誰が？」&「誰の？」のテーブルビュー
        default: fatalError()   // ここにはこない想定
        }
    }
 
}
