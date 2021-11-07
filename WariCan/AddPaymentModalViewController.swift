//
//  AddPaymentModalViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/11/04.
//

import GoogleMobileAds
import UIKit

class AddPaymentModalViewController: UIViewController {

    @IBOutlet private weak var topBannerAdView: GADBannerView!
    @IBOutlet private weak var bottomBannerAdView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAd()
    }
    
    private func setupAd() {
        self.topBannerAdView.adUnitID = WCStringHelper.init().paymentModalTopBannerAdId
        self.topBannerAdView.rootViewController = self
        self.topBannerAdView.load(GADRequest())
        
        self.bottomBannerAdView.adUnitID = WCStringHelper.init().paymentModalBottomBannerAdId
        self.bottomBannerAdView.rootViewController = self
        self.bottomBannerAdView.load(GADRequest())
    }
    
}
