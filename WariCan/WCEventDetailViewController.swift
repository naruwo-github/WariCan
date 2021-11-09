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
    
    private var interstitial: GADInterstitialAd?
    private var payerCellIndex: Int = 0 // 支払い主のセルのインデックス（この値は一つだけ）
    private var debtorCellIndexList: [Int] = [] // 払われた人のインデックスのリスト（初期値は空で）
    private var eventData: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripTitleLabel.text = self.eventData.title
        self.setupAd()
        
        self.paymentTableView.register(UINib(resource: R.nib.wcPaymentCell), forCellReuseIdentifier: "PaymentCell")
        self.setWariCanResultText()
    }
    
    public func setup(eventData: Event) {
        self.eventData = eventData
    }
    
    private func refreshTableViews() {
        self.paymentTableView.reloadData()
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
    
    // 支払い情報入力画面へ遷移する処理
    private func moveToPaymentModal(updatedPayment: Payment?) {
        let personModalVC = R.storyboard.modal.addPaymentModalViewController()!
        personModalVC.modalPresentationStyle = .fullScreen
        personModalVC.setup(
            updatedPayment: updatedPayment,
            eventData: self.eventData,
            payerCellIndex: self.payerCellIndex,
            debtorCellIndexList: self.debtorCellIndexList,
            refreshParentAction: { [unowned self] in
                self.paymentTableView.reloadData()
                self.setWariCanResultText()
            },
            showInterstitialAction: { [unowned self] in
                self.showInterstitialAd()
            }
        )
        self.present(personModalVC, animated: true)
    }
    
    // 「支払いを追加」ボタン
    @IBAction private func addPaymentButtonTapped(_ sender: Any) {
        self.moveToPaymentModal(updatedPayment: nil)
    }
    
    // 「＊初期画面へ」ボタン
    @IBAction private func backToBaseButtonTapped(_ sender: Any) {
        let vc = R.storyboard.main.wcBaseViewController()!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
        return self.eventData.payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! WCPaymentCell
        let payment = self.eventData.payments[indexPath.row]
        cell.setupPayment(payer: payment.payerName, debtorCount: payment.debtor.count.description, type: payment.typeName, price: Int(payment.price).description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            WCRealmHelper.init().delete(object: self.eventData.payments[indexPath.row])
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
        self.refreshTableViews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.moveToPaymentModal(updatedPayment: self.eventData.payments[indexPath.row])
    }
    
}
