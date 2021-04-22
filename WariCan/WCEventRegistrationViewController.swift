//
//  WCEventRegistrationViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/31.
//

import GoogleMobileAds
import UIKit

class WCEventRegistrationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var eventTitleTextField: UITextField!
    @IBOutlet private weak var topWarningLabel: UILabel!
    @IBOutlet private weak var addPeopleButton: UIButton!
    @IBOutlet private weak var peopleWarningLabel: UILabel!
    @IBOutlet private weak var peopleTableView: UITableView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    // 参加者追加モーダル
    @IBOutlet private weak var nameRegisterModalView: UIView!
    @IBOutlet private weak var nameRegisterTextField: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    // TODO: 暫定的に置いてるリスト　Realmでデータを管理すべし
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
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    // TODO: ボタンにシャドゥをつけるのを切り出すか！
    private func setupButtonsLayout() {
        // 円形のボタン
        self.addPeopleButton.layer.cornerRadius = self.addPeopleButton.frame.height / 2.0
        self.addPeopleButton.layer.shadowColor = UIColor.black.cgColor
        self.addPeopleButton.layer.shadowRadius = 4.0
        self.addPeopleButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addPeopleButton.layer.shadowOpacity = 0.4
        
        // 画面下部の「はじめる」ボタン
        self.startButton.layer.cornerRadius = 25
        self.startButton.layer.shadowColor = UIColor.black.cgColor
        self.startButton.layer.shadowRadius = 4.0
        self.startButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.startButton.layer.shadowOpacity = 0.4
        
        // 画面下部の「はじめる」ボタン
        self.backButton.layer.cornerRadius = 20
        self.backButton.layer.shadowColor = UIColor.black.cgColor
        self.backButton.layer.shadowRadius = 4.0
        self.backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.backButton.layer.shadowOpacity = 0.4
        
        // モーダル上の「追加」ボタン
        self.addButton.layer.cornerRadius = 25
        self.addButton.layer.shadowColor = UIColor.black.cgColor
        self.addButton.layer.shadowRadius = 4.0
        self.addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addButton.layer.shadowOpacity = 0.4
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
        // イベント名が入力済みで、参加者が一人以上いればイベント作成
        if !(self.eventTitleTextField.text ?? "").isEmpty
            && self.participantList.count > 0 {
            
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
            vc.tripTitle = self.eventTitleTextField.text!
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
        // イベント名が未入力の場合の警告メッセージ
        if (self.eventTitleTextField.text ?? "").isEmpty {
            self.topWarningLabel.isHidden = false
        }
        // 参加者が一人もいない場合の警告メッセージ
        if self.participantList.count == 0 {
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
        return 50
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
