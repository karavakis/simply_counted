//
//  CheckIn.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class CheckIn: Activity {
    override init() {
        super.init()
        self.className = "CheckIn"
    }

    override init(clientId: String, date: NSDate) {
        super.init(clientId: clientId, date: date)
        self.className = "CheckIn"
    }

    override init(activityObject: PFObject!) {
        super.init(activityObject: activityObject)
        self.className = "CheckIn"
    }
}