//
//  SettingsTableViewCell.swift
//  simply_counted
//
//  Created by Nicholas Karavakis on 2/12/18.
//  Copyright © 2018 Jennifer Karavakis. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var touchIdSwitch: UISwitch!
    @IBOutlet weak var touchIdLabel: UILabel!
    
    let touchAuth = TouchIDAuth()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func touchIdSwitchChanged(_ sender: Any) {
        if touchIdSwitch.isOn { //if toggle is changed to true
            
            touchAuth.authenticateUser() { message in
                if message != nil {
                } else {
                    print("Biometrics has been enabled")
                    UserDefaults.standard.set(true, forKey: "use_touchid")
                }
            }
            
        } else { //if toggle is changed to false
            print("Biometrics has been disabled")
            UserDefaults.standard.set(false, forKey: "use_touchid")
        }
    }
}
