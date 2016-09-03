//
//  PassType.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class PassType: NSObject {
    let id: String
    var passCount: Int
    var price: NSDecimalNumber
    let pfObject: PFObject?

    override init() {
        self.id = ""
        self.passCount = 0
        self.price = 0
        self.pfObject = nil

        super.init()
    }

    init(passCount: Int, price: NSDecimalNumber) {
        self.id = ""
        self.passCount = passCount
        self.price = price
        self.pfObject = nil

        super.init()
    }

    init(activityObject: PFObject!) {
        self.id = activityObject!.objectId!
        self.passCount = activityObject!["passCount"] as! Int
        let priceString = activityObject!["price"] as! String
        self.price = NSDecimalNumber(string: priceString)
        self.pfObject = activityObject
    }

    public func save() {
        let checkIn = PFObject(className: "PassType")
        checkIn["passCount"] = self.passCount
        checkIn["price"] = String(self.price)
        checkIn["user"] = PFUser.currentUser()!
        checkIn.saveInBackground()
    }

    public func deleteCheckIn(deleteSuccess : () -> Void) {
        pfObject!.deleteInBackgroundWithBlock( { (success, error) -> Void in
            if error == nil {
                if success {
                    deleteSuccess()
                }
            } else {
                print("Error : \(error?.localizedDescription) \(error?.userInfo)")
            }
        })
    }

}
