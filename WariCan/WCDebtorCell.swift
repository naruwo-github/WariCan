//
//  WCDebtorCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/10.
//

import UIKit

class WCDebtorCell: UITableViewCell {
    
    @IBOutlet private weak var debtorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupDebtor(debtor: String) {
        self.debtorLabel.text = debtor
    }
}
