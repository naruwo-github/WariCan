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
        self.setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setup() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.backgroundColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 8.0
    }
    
    public func displayName(name: String) {
        self.nameLabel.text = name
    }
    
}
