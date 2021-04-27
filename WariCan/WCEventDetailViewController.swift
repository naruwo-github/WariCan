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
        self.setupTextFieldKeyboard()
        self.setupTableViews()
        self.setWariCanResultText()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
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
        self.setWariCanResultText()
    }
    
    // TODO: 関数内が長くなるので、後で切り出しする
    private func setWariCanResultText() {
        // *** WariCan結果算出アイデア ***
        // ①：全員の出費を算出（払い過ぎは正、払わな過ぎは負）
        // ②：降順でソート（出費過多が先頭に）
        // ③：リストの最後（最大債務者, 出費=L）がリストの最初（最大債権者, F）に min(F, |L|) を支払ってバランスを再計算
        // ④：全員のバランスが 0 になるまで ②-③ を繰り返す
        // ***************************
        
        // ①：全員の出費を算出（払い過ぎは正、払わな過ぎは負）し格納する
        // ["太郎": 6600, "二郎": -1500, "三郎": 1900, ...]の形式
        var balanceDict: Dictionary<String, Double> = [:]
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
            // TODO: 支払い者が自分以外の分を出した場合を考慮してない（Ex. AがBとCだけの料金を払った場合等）
            // 支払い者には、多く払った額を加算する
            balanceDict[payer]! += pricePerPerson * Double(debtorsList.count - 1)
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
        
//        let sortedResultData = resultData.sorted { $0.key < $1.key } // 名前の順でソート
        let sortedResultData = resultData.sorted { $0.value < $1.value } // 名前の順でソート
        var resultText = ""
        for i in sortedResultData {
            // 値はintにして1円単位で出す
            // TODO: 1, 10, 100円単位で丸める操作を選べるようにすべし！
            resultText += i.key + " " + Int(i.value).description + "円" + "\n"
        }
        // 結果のテキストを設定
        self.resultLabel.text = resultText
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
