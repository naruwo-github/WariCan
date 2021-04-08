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
    @IBOutlet private weak var peopleTableView: UITableView!
    @IBOutlet private weak var startButton: UIButton!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.setupButtonsLayout()
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
        
        // モーダル上の「追加」ボタン
        self.addButton.layer.cornerRadius = 25
        self.addButton.layer.shadowColor = UIColor.black.cgColor
        self.addButton.layer.shadowRadius = 4.0
        self.addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addButton.layer.shadowOpacity = 0.4
    }
    
    @IBAction private func addPeopleButtonTapped(_ sender: Any) {
        self.nameRegisterTextField.text = "" // 表示時は何も入力されてない状態にする
        self.nameRegisterModalView.isHidden = false
    }
    
    @IBAction private func startButtonTapped(_ sender: Any) {
        if (self.eventTitleTextField.text ?? "").isEmpty {
            // 警告メッセージ
            self.topWarningLabel.isHidden = false
        } else {
            let vc = R.storyboard.main.wcEventDetailViewController()!
            vc.tripTitle = self.eventTitleTextField.text!
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction private func addButtonTapped(_ sender: Any) {
        if (self.nameRegisterTextField.text ?? "").isEmpty {
            // TODO: 旅行名or参加者が空の場合は赤文字で警告出す？
        } else {
            self.participantList.append(self.nameRegisterTextField.text!)
            self.nameRegisterModalView.isHidden = true
            self.peopleTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell") as! WCPeopleCell
        cell.displayName(name: self.participantList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // タップされたとき
    @IBAction private func eventTitleFocused(_ sender: Any) {
        self.topWarningLabel.isHidden = true
    }
    
    // テキストが入力されているとき
    @IBAction private func eventTitleChanged(_ sender: Any) {
        self.topWarningLabel.isHidden = true
    }
    
}
