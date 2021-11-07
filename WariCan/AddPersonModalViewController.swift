//
//  AddPersonModalViewController.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/11/04.
//

import GoogleMobileAds
import UIKit

class AddPersonModalViewController: UIViewController {
    
    @IBOutlet private weak var topBannerAdView: GADBannerView!
    @IBOutlet private weak var bottomBannerAdView: GADBannerView!
    
    @IBOutlet private weak var nameTextField: UITextField!
    private var addPersonButtonAction: ((UITextField) -> Void)?
    private var initText: String = ""
    
    func setup(action: ((UITextField) -> Void)?, text: String) {
        self.addPersonButtonAction = action
        self.initText = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAd()
        
        self.nameTextField.text = self.initText
        WCUtilityClass().addToolbarOnTextField(view: self.view, textField: self.nameTextField, action: #selector(self.nameRegisterKeyboardCloseButtonTapped))
        // 入力済みの場合は、全選択されるように指定
        self.nameTextField.selectAll(self.nameTextField.text)
        // モーダルを開いたときにフォーカスが当たっているように指定
        self.nameTextField.becomeFirstResponder()
    }
    
    @objc private func nameRegisterKeyboardCloseButtonTapped() {
        self.nameTextField.endEditing(true)
        self.nameTextField.resignFirstResponder()
    }
    
    @IBAction func addPersonButtonTapped(_ sender: Any) {
        self.addPersonButtonAction?(self.nameTextField)
        self.dismiss(animated: true)
    }
    
    private func setupAd() {
        self.topBannerAdView.adUnitID = WCStringHelper.init().personModalTopBannerAdId
        self.topBannerAdView.rootViewController = self
        self.topBannerAdView.load(GADRequest())
        
        self.bottomBannerAdView.adUnitID = WCStringHelper.init().personModalBottomBannerAdId
        self.bottomBannerAdView.rootViewController = self
        self.bottomBannerAdView.load(GADRequest())
    }
}
