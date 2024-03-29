//
//  WCEventRegistrationViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/31.
//

import GoogleMobileAds
import UIKit

// MARK: イベント作成画面のVC
class WCEventRegistrationViewController: UIViewController {
    
    @IBOutlet private weak var eventTitleTextField: UITextField!
    @IBOutlet private weak var topWarningLabel: UILabel!
    @IBOutlet private weak var addPeopleButton: WCCustomUIButton!
    @IBOutlet private weak var peopleWarningLabel: UILabel!
    @IBOutlet private weak var peopleTableView: UITableView!
    @IBOutlet private weak var startButton: WCCustomUIButton!
    @IBOutlet private weak var backButton: WCCustomUIButton!
    
    @IBOutlet private weak var topBannerView: GADBannerView!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    // 参加者のリスト（この画面内ではDBに保存せず一時的にクラス内部で保持）
    private var participantList: [String] = []
    // 参加者名の編集中を表すフラグ
    private var peopleNameEdittingFlag = false
    // 編集中のparticipantListを表すインデックス
    private var edittingIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.setupButtonsLayout()
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.eventTitleTextField, action: #selector(self.eventTitleKeyboardCloseButtonTapped))
        self.peopleTableView.register(UINib(resource: R.nib.wcPeopleCell), forCellReuseIdentifier: "PeopleCell")
    }
    
    private func setupAd() {
        self.topBannerView.adUnitID = WCStringHelper.init().eventRegistrationVCTopBannerAdId
        self.topBannerView.rootViewController = self
        self.topBannerView.load(GADRequest())
        
        self.bottomBannerView.adUnitID = WCStringHelper.init().eventRegistrationVCBottomBannerAdId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    private func setupButtonsLayout() {
        // 円形のボタン
        self.addPeopleButton.layer.cornerRadius = self.addPeopleButton.frame.height / 2.0
    }
    
    @objc private func eventTitleKeyboardCloseButtonTapped() {
        self.eventTitleTextField.endEditing(true)
        self.eventTitleTextField.resignFirstResponder()
    }
    
    private func addPersonAction(personNameTextField: UITextField) {
        if (personNameTextField.text ?? "").isEmpty {
            // 参加者ラベルが空なら、追加しない、何もしない
        } else {
            if self.peopleNameEdittingFlag {
                self.peopleNameEdittingFlag = false
                // 既存の参加者名の編集中である場合
                self.participantList[self.edittingIndex] = personNameTextField.text!
            } else {
                // 新規の参加者を追加する場合
                self.participantList.append(personNameTextField.text!)
            }
            personNameTextField.resignFirstResponder()
            self.peopleWarningLabel.isHidden = true
            self.peopleTableView.reloadData()
        }
    }
    
    @IBAction private func addPeopleButtonTapped(_ sender: Any) {
        let personModalVC = R.storyboard.modal.addPersonModalViewController()!
        personModalVC.setup(action: { personNameTextField in
            self.addPersonAction(personNameTextField: personNameTextField)
        }, text: "")
        self.present(personModalVC, animated: true)
    }
    
    @IBAction private func startButtonTapped(_ sender: Any) {
        // イベント名が入力済みで、参加者が2人以上いればイベント作成
        if !(self.eventTitleTextField.text ?? "").isEmpty
            && self.participantList.count >= 2 {
            
            // **イベントデータ保存**
            let event = Event()
            event.title = self.eventTitleTextField.text!
            for person in self.participantList {
                let participant = Participant()
                participant.name = person
                event.participants.append(participant)
            }
            WCRealmHelper.init().add(object: event)
            // ******************
            
            let vc = R.storyboard.main.wcEventDetailViewController()!
            vc.setup(eventData: event)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
        // イベント名が未入力の場合の警告メッセージ
        if (self.eventTitleTextField.text ?? "").isEmpty {
            self.topWarningLabel.isHidden = false
        }
        // 参加者が2人未満の場合の警告メッセージ
        if self.participantList.count < 2 {
            self.peopleWarningLabel.isHidden = false
        }
    }
    
    @IBAction private func backButtonTapped(_ sender: Any) {
        let vc = R.storyboard.main.wcBaseViewController()!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // 「名前は？」フィールドがタップされたとき
    @IBAction private func eventTitleFocused(_ sender: Any) {
        self.topWarningLabel.isHidden = true
    }
    
    // 「名前は？」フィールドのテキストが入力中のとき
    @IBAction private func eventTitleChanged(_ sender: Any) {
        self.topWarningLabel.isHidden = true
    }
    
}

// MARK: UITableViewの設定のための拡張
extension WCEventRegistrationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participantList.count
    }
    
    // セルの情報やレイアウトを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell") as! WCPeopleCell
        cell.displayName(name: self.participantList[indexPath.row])
        return cell
    }
    
    // 参加者セルの削除処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.participantList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    // 参加者セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WCPeopleCell
        
        self.peopleNameEdittingFlag = true
        self.edittingIndex = indexPath.row
        
        let personModalVC = R.storyboard.modal.addPersonModalViewController()!
        personModalVC.setup(action: { personNameTextField in
            self.addPersonAction(personNameTextField: personNameTextField)
        }, text: cell.getName())
        self.present(personModalVC, animated: true)
    }
    
}
