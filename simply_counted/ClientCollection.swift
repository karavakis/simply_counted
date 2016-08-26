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
        let query = PFQuery(className:"Client")
        if let currentUser = PFUser.currentUser() {
            query.whereKey("user", equalTo:currentUser)
            query.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        self.clients = [String : Client]()
                        for object in objects {
                            let newClient = Client(clientObject : object)
                            self.clients[newClient.id] = newClient
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