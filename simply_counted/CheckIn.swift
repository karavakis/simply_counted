//
//  CheckIn.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class CheckIn: NSObject {

    let id: Int
    var clientId: String
    var date: NSDate
    let pfObject: PFObject?

    override init() {
        self.id = NSDate().hashValue
        self.clientId = ""
        self.date = NSDate()
        self.pfObject = nil

        super.init()
    }

    init(clientId: String, date: NSDate) {
        self.id = NSDate().hashValue
        self.clientId = clientId
        self.date = date
        self.pfObject = nil

        super.init()
    }

    init(checkInObject: PFObject!) {
        self.id = checkInObject!["id"] as! Int
        self.clientId = checkInObject!["clientId"] as! String
        self.date = checkInObject!["date"] as! NSDate
        self.pfObject = checkInObject
    }

    public func save() {
        let checkIn = PFObject(className: "CheckIn")
        checkIn["id"] = self.id
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