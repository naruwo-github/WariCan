//
//  WCCustomUIButton.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/23.
//

import UIKit

@IBDesignable
// MARK: - <カスタムしたUIButtonのクラス>
class WCCustomUIButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var enableShadow: Bool = false {
        didSet {
            self.setButtonShadow()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.setButtonShadow()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.2 {
        didSet {
            self.setButtonShadow()
        }
    
    }
    @IBInspectable var shadowRadius: CGFloat = 4.0 {
        didSet {
            self.setButtonShadow()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 2.0, height: 2.0) {
        didSet {
            self.setButtonShadow()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    private func setButtonShadow() {
        if self.enableShadow {
            self.clipsToBounds = false
            self.layer.shadowOffset = self.shadowOffset
            self.layer.shadowColor = self.shadowColor.cgColor
            self.layer.shadowRadius = self.shadowRadius
            self.layer.shadowOpacity = self.shadowOpacity
        } else {
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shadowColor = nil
            self.layer.shadowOpacity = 0
        }
    }
    
}
