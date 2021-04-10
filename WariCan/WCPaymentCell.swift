//
//  WCPaymentCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/10.
//

import UIKit

class WCPaymentCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setup() {
        // 仮のレイアウト
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.backgroundColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 8.0
    }
    
}
