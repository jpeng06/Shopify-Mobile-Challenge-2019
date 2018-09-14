//
//  ListTableViewCell.swift
//  ShopiList
//
//  Created by John Peng on 2018-09-12.
//  Copyright © 2018 Junhao Peng. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var productImg: UIImageView!
    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productInventory: UILabel!
    
    
    var isCellSelected:Bool = false {
        didSet {
            //self.heightConstraint.constant = isCellSelected ? 100 : 0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
