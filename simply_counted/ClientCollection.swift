//
//  ClientCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class ClientCollection: CloudKitContainer {

    var clients = [CKRecordID: Client]()

    override init() {
        super.init()
    }

    subscript(id:CKRecordID) -> Client? {
        return self.clients[id]
    }

    public func count() -> Int {
        return self.clients.count
    }

    public func append(client:Client) {
        clients[client.record!.recordID] = client
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

    func load(successHandler:(()->Void)) {

        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Client", predicate: predicate)

        func createClientList(records: [CKRecord]) {
            self.clients.removeAll()
            for record in records {
                let newClient = Client(clientRecord : record)
                self.clients[newClient.record!.recordID] = newClient
            }
            successHandler()
        }

        func errorHandler(error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createClientList, errorHandler: errorHandler)
    }
}