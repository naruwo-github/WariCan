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
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    @IBOutlet private weak var nameRegisterModalView: UIView!
    @IBOutlet private weak var nameRegisterTextField: UITextField!
    @IBOutlet private weak var addButton: WCCustomUIButton!
    
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
        self.setupTextFieldKeyboard()
        self.peopleTableView.register(UINib(resource: R.nib.wcPeopleCell), forCellReuseIdentifier: "PeopleCell")
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = WCStringHelper.init().eventRegistrationVCBottomBannerAdId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    private func setupButtonsLayout() {
        // 円形のボタン
        self.addPeopleButton.layer.cornerRadius = self.addPeopleButton.frame.height / 2.0
    }
    
    private func setupTextFieldKeyboard() {
        // イベント名入力のキーボードに対して
        let eventToolbar = UIToolbar()
        eventToolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let eventSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self.eventTitleTextField, action: nil)
        let eventTitleKeyboardCloseButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.eventTitleKeyboardCloseButtonTapped))
        eventToolbar.items = [eventSpacer, eventTitleKeyboardCloseButton]
        self.eventTitleTextField.inputAccessoryView = eventToolbar
        
        // 人名入力のキーボードに対して
        let nameToolbar = UIToolbar()
        nameToolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let nameSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self.nameRegisterTextField, action: nil)
        let nameTitleKeyboardCloseButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.nameRegisterKeyboardCloseButtonTapped))
        nameToolbar.items = [nameSpacer, nameTitleKeyboardCloseButton]
        self.nameRegisterTextField.inputAccessoryView = nameToolbar
    }
    
    @objc private func eventTitleKeyboardCloseButtonTapped() {
        self.eventTitleTextField.endEditing(true)
        self.eventTitleTextField.resignFirstResponder()
    }
    
    @objc private func nameRegisterKeyboardCloseButtonTapped() {
        self.nameRegisterTextField.endEditing(true)
        self.nameRegisterTextField.resignFirstResponder()
    }
    
    // 参加者追加モーダルを表示　参加者名のフィールドに入る文字はnameFieldTextで指定
    private func showModalView(nameFieldText: String) {
        self.nameRegisterTextField.text = nameFieldText
        self.nameRegisterModalView.isHidden = false
    }
    
    // 丸い「＋」ボタン
    @IBAction private func addPeopleButtonTapped(_ sender: Any) {
        // ボタン経由で表示する場合は何も入力されてない状態にする
        self.showModalView(nameFieldText: "")
    }
    
    // 「はじめる」ボタン
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
    
    // 「もどる」ボタン
    @IBAction private func backButtonTapped(_ sender: Any) {
        let vc = R.storyboard.main.wcBaseViewController()!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // 「追加」ボタン
    @IBAction private func addButtonTapped(_ sender: Any) {
        if (self.nameRegisterTextField.text ?? "").isEmpty {
            // 参加者ラベルが空なら、追加しない、何もしない
        } else {
            if self.peopleNameEdittingFlag {
                self.peopleNameEdittingFlag = false
                // 既存の参加者名の編集中である場合
                self.participantList[self.edittingIndex] = self.nameRegisterTextField.text!
            } else {
                // 新規の参加者を追加する場合
                self.participantList.append(self.nameRegisterTextField.text!)
            }
            self.nameRegisterTextField.resignFirstResponder()
            self.peopleWarningLabel.isHidden = true
            self.nameRegisterModalView.isHidden = true
            self.peopleTableView.reloadData()
        }
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
    
    // セルの個数を設定
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
        self.showModalView(nameFieldText: cell.getName())
    }
    
    // セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}
