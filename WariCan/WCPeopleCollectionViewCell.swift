//
//  WCPeopleCollectionViewCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/03/31.
//

import UIKit

class WCPeopleCollectionViewCell: UICollectionViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.backgroundColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 8.0
    }
    
    public func displayName(name: String) {
        //
    }
    
}
