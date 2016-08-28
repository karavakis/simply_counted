//
//  ClassCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class ClassCollection: NSObject {

    //Make an array for each month
    var classDates = [ClassDate]()

    override init() {
        super.init()
    }

    subscript(id:Int) -> ClassDate? {
        return self.classDates[id]
    }

    public func count() -> Int {
        return self.classDates.count
    }

    public func load(success : () -> Void) {
        classDates = [ClassDate]()
        let query = PFQuery(className:"CheckIn")
        if let currentUser = PFUser.currentUser() {
            query.whereKey("user", equalTo:currentUser)
            query.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            let newCheckIn = CheckIn(activityObject : object)
                            var foundDate = false
                            for classDate in self.classDates {
                                if(NSCalendar.currentCalendar().isDate(classDate.date, inSameDayAsDate: newCheckIn.date)) {
                                    classDate.append(newCheckIn)
                                    foundDate = true
                                    break
                                }
                            }
                            if( !foundDate ) {
                                let newClassDate = ClassDate(checkIn: newCheckIn)
                                self.classDates.append(newClassDate)
                            }
                        }
                        self.classDates.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
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