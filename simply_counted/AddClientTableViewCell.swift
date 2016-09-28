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
    
    var completionHandler:((_ client: Client)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButtonClicked(_ sender: AnyObject) {
        
        if let name = self.nameTextField.text {
            if name != "" {
                let newClient = Client(name: name)

                func saveComplete() {
                    self.savedLabel.isHidden = true
                    self.addButton.isHidden = false
                    if self.completionHandler != nil {
                        self.completionHandler?(newClient)
                    }
                }

                newClient.save(saveComplete)

                self.nameTextField.text = ""
                self.addButton.isHidden = true
                self.savedLabel.isHidden = false
            }
        }
    }
}
