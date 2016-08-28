//
//  ClientCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

public class ClientCollection: NSObject {

    var clients = [String: Client]()

    override init() {
        super.init()
    }

    subscript(id:String) -> Client? {
        return self.clients[id]
    }

    public func count() -> Int {
        return self.clients.count
    }

    func getIndexedList() -> [String:[Client]] {
        var indexedList = [String:[Client]]()

        for client in clients.values
        {
            let firstLetter = String(client.name[client.name.startIndex]).uppercaseString

            if (indexedList[firstLetter] != nil) {
                indexedList[firstLetter]!.append(client)
            }
            else {
                indexedList[firstLetter] = [Client]()
                indexedList[firstLetter]!.append(client)
            }
        }
        return indexedList
    }

    public func load(success : () -> Void) {
        let getClients = PFQuery(className:"Client")
        if let currentUser = PFUser.currentUser() {
            getClients.whereKey("user", equalTo:currentUser)
            getClients.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        self.clients.removeAll()
                        for object in objects {
                            let newClient = Client(clientObject : object)

                            //get check-ins
                            let getCheckIns = PFQuery(className: "CheckIn")
                            getCheckIns.whereKey("user", equalTo:currentUser)
                            getCheckIns.whereKey("clientId", equalTo:newClient.id)
                            getCheckIns.addDescendingOrder("date")
                            do {
                                let objects = try getCheckIns.findObjects()
                                for object in objects {
                                    let newCheckIn = CheckIn(activityObject : object)
                                    newClient.activities.append(newCheckIn)
                                }
                                if let lastCheckIn = newClient.activities.first {
                                    newClient.lastCheckIn = lastCheckIn.date
                                }
                                self.clients[newClient.id] = newClient
                            }
                            catch let error as NSError {
                                print("Error: \(error) \(error.userInfo)")
                            }
                        }
                        success()
                    }
                }
                else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
}