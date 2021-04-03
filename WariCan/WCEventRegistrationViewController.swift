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
    @IBOutlet private weak var peopleCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    private var peopleNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.setupButtonsLayout()
        self.setupCollectionView()
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
    
    private func setupCollectionView() {
        let colViewWid = self.peopleCollectionView.frame.width
        self.peopleCollectionViewFlowLayout.estimatedItemSize = CGSize(width: colViewWid / 3.0 - colViewWid / 10.0, height: 60)
    }
    
    @IBAction private func addPeopleButtonTapped(_ sender: Any) {
        peopleNumber += 1
        self.peopleCollectionView.reloadData()
    }
    
    @IBAction private func startButtonTapped(_ sender: Any) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: 参加者の数を返すようにする
        return peopleNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCell", for: indexPath)
        // TODO: ここでセルを整形して返す
        return cell
    }
    
}
