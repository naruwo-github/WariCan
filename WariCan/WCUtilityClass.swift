//
//  WCUtilityClass.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/09/06.
//

import UIKit

// MARK: - ユーティリティクラス（汎用化したオープンクラスを定義するクラス）
class WCUtilityClass {
    
    class func addToolbarOnTextField(view: UIView, textField: UITextField, action: Selector?) {
        let priceToolbar = UIToolbar()
        priceToolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        let priceSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: textField, action: nil)
        let priceKeyboardCloseButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: action)
        priceToolbar.items = [priceSpacer, priceKeyboardCloseButton]
        textField.inputAccessoryView = priceToolbar
    }
    
}
