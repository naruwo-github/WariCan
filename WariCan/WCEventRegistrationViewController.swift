//
//  WCEventRegistrationViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/31.
//

import GoogleMobileAds
import UIKit

class WCEventRegistrationViewController: UIViewController {
    
    @IBOutlet private weak var bottomBannerView: GADBannerView!
    
    private let adTestId = "ca-app-pub-3940256099942544/2934735716"
    // TODO: リリースビルドでは、本物の広告IDを使う！
    private let adId = "ca-app-pub-6492692627915720/6116539333"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
    }
    
    private func setupAd() {
        self.bottomBannerView.adUnitID = adTestId
        self.bottomBannerView.rootViewController = self
        self.bottomBannerView.load(GADRequest())
    }
    
}
