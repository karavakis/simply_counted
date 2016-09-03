//
//  AddPassTypeTableViewCell.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class AddPassTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var passCountTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var savedLabel: UILabel!

    var completionHandler:(()->Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButtonClicked(sender: AnyObject) {

        if let passCountString = self.passCountTextField.text {
            if let passCount = Int(passCountString) {
                if let priceString = self.priceTextField.text {
                    let price = priceString == "" ? NSDecimalNumber(integer: 0) : NSDecimalNumber(string: priceString)
                    let newPassType = PassType(passCount: passCount, price: price)
                    newPassType.save()

                    self.passCountTextField.text = ""
                    self.priceTextField.text = ""
                    self.addButton.hidden = true
                    self.savedLabel.hidden = false

                    delay(1.0) {
                        self.addButton.hidden = false
                        self.savedLabel.hidden = true
                        if self.completionHandler != nil {
                            self.completionHandler()
                        }
                    }
                }
            }
        }
    }
}
