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
    var activities = [Activity]()
    var pfObject: PFObject? = nil
    var checkInsLoaded = false
    var lastCheckIn : NSDate? = nil


    /****************/
    /* Initializers */
    /****************/
    override init() {
        self.id = ""
        self.name = "name"
        self.passes = 0

        super.init()
    }

    init(name: String, passes: Int) {
        checkInsLoaded = false
        self.id = ""
        self.name = name
        self.passes = passes

        super.init()
//        self.loadActivity(activityLoadSuccess)
    }

    init(clientObject: PFObject!) {
        checkInsLoaded = false
        self.id = clientObject!.objectId!
        self.name = clientObject!["name"] as! String
        self.passes = clientObject!["passes"] as! Int
        self.pfObject = clientObject

        super.init()
//        self.loadActivity(activityLoadSuccess)
    }


    /****************/
    /* DB Functions */
    /****************/
    public func update() {
        if let client : PFObject = pfObject! {
            client["name"] = self.name
            client["passes"] = self.passes
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
        self.activities.append(checkIn)
        self.passes = self.passes - 1
        self.update() 
    }

    /**********/
    /* Passes */
    /**********/
    public func addPasses(passesAdded: Int) {
        self.passes += passesAdded
        let passActivity = PassActivity(clientId: self.id, date: NSDate(), passesAdded: passesAdded)
        passActivity.save()
        self.activities.append(passActivity)
        self.update()
    }
}