//
//  PassTypeCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class PassTypeCollection: CloudKitContainer {

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

    public func add(passType: PassType) {
        passTypes.append(passType)
        passTypes.sortInPlace { $0.passCount > $1.passCount }
        passTypes.sortInPlace { $0.price.compare($1.price) == .OrderedDescending }
    }

    public func removeAtIndex(index:Int) -> Void {
        passTypes.removeAtIndex(index)
    }

    public func load(successHandler:(()->Void)) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let sortPassCount = NSSortDescriptor(key: "passCount", ascending: false)
        let sortPrice = NSSortDescriptor(key: "price", ascending: false)
        let query = CKQuery(recordType: "PassType", predicate: predicate)
        query.sortDescriptors = [sortPassCount, sortPrice]

        func createPassTypeLists(records: [CKRecord]) {
            passTypes = [PassType]()

            for record in records {
                let newPassType = PassType(passTypeRecord : record)
                self.passTypes.append(newPassType)
            }
            successHandler()
        }

        func errorHandler(error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createPassTypeLists, errorHandler: errorHandler)
    }
}