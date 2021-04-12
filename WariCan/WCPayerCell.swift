//
//  WCPayerCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/10.
//

import UIKit

class WCPayerCell: UITableViewCell {
    
    @IBOutlet private weak var payerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupPayer(payer: String) {
        self.payerLabel.text = payer
    }
    
}
