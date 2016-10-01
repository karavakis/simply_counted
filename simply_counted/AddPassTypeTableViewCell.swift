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

    var completionHandler:((_ passType:PassType)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButtonClicked(_ sender: AnyObject) {

        if let passCountString = self.passCountTextField.text {
            if let passCount = Int(passCountString) {
                if let priceString = self.priceTextField.text {
                    let price = priceString == "" ? "0" : priceString
                    let newPassType = PassType(passCount: passCount, price: price)

                    func saveComplete() {
                        self.addButton.isHidden = false
                        self.savedLabel.isHidden = true
                        if self.completionHandler != nil {
                            self.completionHandler?(newPassType)
                        }
                    }

                    newPassType.save(saveComplete)

                    self.passCountTextField.text = ""
                    self.priceTextField.text = ""
                    self.addButton.isHidden = true
                    self.savedLabel.isHidden = false
                }
            }
        }
    }
}
