//
//  Client.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class Client: NSObject {

    let id: String
    var name: String
    var passes: Int
    var notes : String
    var activities = [Activity]()
    var pfObject: PFObject? = nil
    var lastCheckIn : NSDate? = nil


    /****************/
    /* Initializers */
    /****************/
    override init() {
        self.id = ""
        self.name = "name"
        self.notes = ""
        self.passes = 0

        super.init()
    }

    init(name: String) {
        self.id = ""
        self.name = name
        self.passes = 0
        self.notes = ""

        super.init()
    }

    init(clientObject: PFObject!) {
        self.id = clientObject!.objectId!
        self.name = clientObject!["name"] as! String
        self.passes = clientObject!["passes"] as! Int
        self.notes = clientObject!["notes"] as! String
        self.lastCheckIn = clientObject!["lastCheckIn"] as? NSDate
        self.pfObject = clientObject

        super.init()
    }


    /****************/
    /* DB Functions */
    /****************/
    public func update() {
        if let client : PFObject = pfObject! {
            client["name"] = self.name
            client["passes"] = self.passes
            client["notes"] = self.notes
            if let lastCheckIn = self.lastCheckIn {
                client["lastCheckIn"] = lastCheckIn
            }
            client.saveInBackground()
        }
        else {
            self.save()
        }
    }

    public func save() {
        let client = PFObject(className: "Client")
        client["name"] = self.name
        client["passes"] = self.passes
        client["notes"] = self.notes
        if let lastCheckIn = self.lastCheckIn {
            client["lastCheckIn"] = lastCheckIn
        }
        client["user"] = PFUser.currentUser()!
        client.saveInBackground()
    }

    public func deleteClient(deleteSuccess : () -> Void) {
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

    /*************/
    /* Check-Ins */
    /*************/

    public func checkIn(date: NSDate) {
        let checkIn = CheckIn(clientId: self.id, date: date)
        checkIn.save()
        self.activities.insert(checkIn, atIndex: 0)
        self.passes = self.passes - 1
        self.updateLastCheckIn(date)
        self.update()
    }

    func updateLastCheckIn(newCheckIn: NSDate) {
        if let lastCheckIn = self.lastCheckIn {
            if(lastCheckIn.compare(newCheckIn) == NSComparisonResult.OrderedDescending) {
                //do not update lastCheckIn
                return
            }
        }
        self.lastCheckIn = newCheckIn
    }

    /**********/
    /* Passes */
    /**********/
    public func addPasses(passesAdded: Int) {
        self.passes += passesAdded
        self.update()
        let passActivity = PassActivity(clientId: self.id, date: NSDate(), passesAdded: passesAdded)
        passActivity.save()
        self.activities.insert(passActivity, atIndex: 0)
    }

    /**************/
    /* Activities */
    /**************/
    public func loadActivities(success : () -> Void) {
        //get check-ins
        let getCheckIns = PFQuery(className: "CheckIn")
        if let currentUser = PFUser.currentUser() {
            getCheckIns.whereKey("user", equalTo:currentUser)
            getCheckIns.whereKey("clientId", equalTo:self.id)
            getCheckIns.addDescendingOrder("date")
            getCheckIns.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    if let checkInObjects = objects {

                        //get pass activities
                        let getPassActivities = PFQuery(className: "PassActivity")
                        getPassActivities.whereKey("user", equalTo:currentUser)
                        getPassActivities.whereKey("clientId", equalTo:self.id)
                        getPassActivities.addAscendingOrder("date")
                        getPassActivities.findObjectsInBackgroundWithBlock {
                            (objects:[PFObject]?, error:NSError?) -> Void in
                            if error == nil {
                                if let objects = objects {
                                    var passActivityObjects = objects
                                    func getNextPassActivity() -> PassActivity? {
                                        if let nextPassActivityObject = passActivityObjects.popLast() {
                                            return PassActivity(activityObject: nextPassActivityObject)
                                        }
                                        return nil
                                    }

                                    var nextPassActivity = getNextPassActivity()
                                    for checkInObject in checkInObjects {
                                        let newCheckIn = CheckIn(activityObject : checkInObject)

                                        //Append any Pass Activity that occurs before this checkIn
                                        while(nextPassActivity != nil && nextPassActivity!.date.compare(newCheckIn.date) == NSComparisonResult.OrderedDescending) {
                                            self.activities.append(nextPassActivity!)
                                            nextPassActivity = getNextPassActivity()
                                        }

                                        self.activities.append(newCheckIn)
                                    }
                                    while(nextPassActivity != nil) {
                                        self.activities.append(nextPassActivity!)
                                        nextPassActivity = getNextPassActivity()
                                    }
                                    if let lastCheckInObject = checkInObjects.first {
                                        self.lastCheckIn = lastCheckInObject["date"] as? NSDate
                                    }
                                    success()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}