//
//  WCPaymentCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/10.
//

import UIKit

class WCPaymentCell: UITableViewCell {
    
    @IBOutlet private weak var payerLabel: UILabel!
    @IBOutlet private weak var debtorLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupPayment(payer: String, debtor: String, type: String, price: String) {
        self.payerLabel.text = payer
        self.debtorLabel.text = debtor
        self.typeLabel.text = type
        self.priceLabel.text = price
    }
    
}
