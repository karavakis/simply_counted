//
//  PassActivity.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/26/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class PassActivity: Activity {
    var passesAdded : Int
    var price : String

    override init() {
        self.passesAdded = 0
        self.price = "0"
        super.init()
        self.className = "PassActivity"
    }

    override init(clientId: String, date: NSDate) {
        self.passesAdded = 0
        self.price = "0"
        super.init(clientId: clientId, date: date)
        self.className = "PassActivity"
    }

    init(clientId: String, date: NSDate, passType: PassType) {
        self.passesAdded = passType.passCount
        self.price = String(passType.price)
        super.init(clientId: clientId, date: date)
        self.className = "PassActivity"
    }

    override init(activityObject: PFObject!) {
        self.passesAdded = activityObject!["passesAdded"] as! Int
        self.price = activityObject!["price"] as! String
        super.init(activityObject: activityObject)
        self.className = "PassActivity"
    }

    //TODO use better inheritance method
    override public func save() {
        let passActivity = PFObject(className: className)
        passActivity["clientId"] = self.clientId
        passActivity["date"] = self.date
        passActivity["passesAdded"] = self.passesAdded
        passActivity["price"] = self.price
        passActivity["user"] = PFUser.currentUser()!
        passActivity.saveInBackground()
    }
}