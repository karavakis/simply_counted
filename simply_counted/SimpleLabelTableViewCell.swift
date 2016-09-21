//
//  SimpleLabelTableViewCell.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/20/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class SimpleLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
