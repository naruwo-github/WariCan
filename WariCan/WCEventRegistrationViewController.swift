//
//  WCEventRegistrationViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/31.
//

import GoogleMobileAds
import UIKit

class WCEventRegistrationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet private weak var eventTitleTextField: UITextField!
    @IBOutlet private weak var addPeopleButton: UIButton!
    @IBOutlet private weak var peopleCollectionView: UICollectionView!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.setupButtonsLayout()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
    private func setupButtonsLayout() {
        self.addPeopleButton.layer.cornerRadius = self.addPeopleButton.frame.height / 2.0
        self.addPeopleButton.layer.shadowColor = UIColor.black.cgColor
        self.addPeopleButton.layer.shadowRadius = 4.0
        self.addPeopleButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.addPeopleButton.layer.shadowOpacity = 0.4
        
        self.startButton.layer.cornerRadius = 25
        self.startButton.layer.shadowColor = UIColor.black.cgColor
        self.startButton.layer.shadowRadius = 4.0
        self.startButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.startButton.layer.shadowOpacity = 0.4
    }
    
    @IBAction private func addPeopleButtonTapped(_ sender: Any) {
    }
    
    @IBAction private func startButtonTapped(_ sender: Any) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: 参加者の数を返すようにする
        return 0 // なんかこれを1に書き換えると落ちる。セル定義してないからかな。
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO: 追加した参加者の名前を表示して返すようにする
        return UICollectionViewCell()
    }
    
}
