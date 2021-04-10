//
//  WCEventCell.swift
//  WariCan
//
//  Created by Narumi Nogawa on 2021/04/10.
//

import UIKit

class WCEventCell: UITableViewCell {
    
    @IBOutlet private weak var eventLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupEvent(event: String) {
        self.eventLabel.text = event
    }
    
    public func getEventTitle() -> String {
        return self.eventLabel.text ?? ""
    }
}
