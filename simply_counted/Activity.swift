//
//  Activity.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/26/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class Activity: NSObject {

    let id: String
    var clientId: String
    var date: NSDate
    let pfObject: PFObject?
    var className = "Activity"

    override init() {
        self.id = ""
        self.clientId = ""
        self.date = NSDate()
        self.pfObject = nil

        super.init()
    }

    init(clientId: String, date: NSDate) {
        self.id = ""
        self.clientId = clientId
        self.date = date
        self.pfObject = nil

        super.init()
    }

    init(activityObject: PFObject!) {
        self.id = activityObject!.objectId!
        self.clientId = activityObject!["clientId"] as! String
        self.date = activityObject!["date"] as! NSDate
        self.pfObject = activityObject
    }

    public func save() {
        let checkIn = PFObject(className: className)
        checkIn["clientId"] = self.clientId
        checkIn["date"] = self.date
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