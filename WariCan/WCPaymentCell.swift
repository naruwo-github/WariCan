//
//  WCPaymentCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/10.
//

import UIKit

class WCPaymentCell: UITableViewCell {
    
    @IBOutlet private weak var upperLabel: UILabel!
    @IBOutlet private weak var lowerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupPayment(payer: String, debtorCount: String, type: String, price: String) {
        self.upperLabel.text = payer + "が " + debtorCount + "人分の " + type + "で"
        self.lowerLabel.text = "¥ " + price + " 円"
    }
    
}
