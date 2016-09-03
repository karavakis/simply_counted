//
//  PassTypeCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class PassTypeCollection: NSObject {

    //Make an array for each month
    var passTypes = [PassType]()

    override init() {
        super.init()
    }

    subscript(id:Int) -> PassType? {
        return self.passTypes[id]
    }

    public func count() -> Int {
        return self.passTypes.count
    }

    public func load(success : () -> Void) {
        passTypes = [PassType]()
        let query = PFQuery(className:"PassType")
        if let currentUser = PFUser.currentUser() {
            query.whereKey("user", equalTo:currentUser)
            query.orderByAscending("passCount,price")
            query.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            let newPassType = PassType(activityObject : object)
                            self.passTypes.append(newPassType)
                        }
                        success()
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
}