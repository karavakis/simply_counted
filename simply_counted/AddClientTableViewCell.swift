//
//  AddClientTableViewCell.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

class AddClientTableViewCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var presentInView: UIView!
    
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
        
        if let name = self.nameTextField.text {
            if name != "" {
                let newClient = Client(name: name, passes:0)
                newClient.save()

                self.nameTextField.text = ""
                self.addButton.hidden = true
                self.savedLabel.hidden = false
                delay(1.0) {
                    self.savedLabel.hidden = true
                    self.addButton.hidden = false
                    if self.completionHandler != nil {
                        self.completionHandler()
                    }
                }
            }
        }
    }
}
