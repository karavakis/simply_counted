//
//  ClientCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class ClientCollection: CloudKitContainer {

    var clients = [CKRecord.ID: Client]()

    override init() {
        super.init()
    }

    subscript(id:CKRecord.ID) -> Client? {
        return self.clients[id]
    }

    open func count() -> Int {
        return self.clients.count
    }

    open func append(_ client:Client) {
        clients[client.record!.recordID] = client
    }

    open func removeValue(forId: CKRecord.ID) {
        clients.removeValue(forKey: forId)
    }

    func getIndexedList() -> [String:[Client]] {
        var indexedList = [String:[Client]]()

        for client in clients.values
        {
            let firstLetter = String(client.name[client.name.startIndex]).uppercased()

            if (indexedList[firstLetter] != nil) {
                indexedList[firstLetter]!.append(client)
            }
            else {
                indexedList[firstLetter] = [Client]()
                indexedList[firstLetter]!.append(client)
            }
        }
        var indexedListSorted = [String:[Client]]()
        for list in indexedList {
            indexedListSorted[list.key] = list.value.sorted(by: { $0.name < $1.name })
        }
        return indexedListSorted
    }

    func load(successHandler:@escaping (()->Void), errorHandler: @escaping (()->Void)) {

        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Client", predicate: predicate)
        let sort = NSSortDescriptor(key: "name", ascending: true)

        func createClientList(_ records: [CKRecord]) {
            self.clients.removeAll()
            for record in records {
                let newClient = Client(clientRecord : record)
                self.clients[newClient.record!.recordID] = newClient
            }
            successHandler()
        }

        func handleError(_ error: NSError) {
            print("Error: \(error) \(error.userInfo)")
            errorHandler()
        }

        performQuery(query, successHandler: createClientList, errorHandler: handleError)
    }
}
