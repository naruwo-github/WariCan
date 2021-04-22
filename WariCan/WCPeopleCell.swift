//
//  WCPeopleCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/03.
//

import UIKit

class WCPeopleCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func displayName(name: String) {
        self.nameLabel.text = name
    }
    
    public func getName() -> String {
        return self.nameLabel.text ?? ""
    }
    
}
