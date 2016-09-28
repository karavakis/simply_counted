//
//  PassTypeCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class PassTypeCollection: CloudKitContainer {

    //Make an array for each month
    var passTypes = [PassType]()

    override init() {
        super.init()
    }

    subscript(id:Int) -> PassType? {
        return self.passTypes[id]
    }

    open func count() -> Int {
        return self.passTypes.count
    }

    open func add(_ passType: PassType) {
        passTypes.append(passType)
        passTypes.sort { $0.passCount > $1.passCount }
        passTypes.sort { $0.price.compare($1.price) == .orderedDescending }
    }

    open func removeAtIndex(_ index:Int) -> Void {
        passTypes.remove(at: index)
    }

    open func load(_ successHandler:@escaping (()->Void)) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let sortPassCount = NSSortDescriptor(key: "passCount", ascending: false)
        let sortPrice = NSSortDescriptor(key: "price", ascending: false)
        let query = CKQuery(recordType: "PassType", predicate: predicate)
        query.sortDescriptors = [sortPassCount, sortPrice]

        func createPassTypeLists(_ records: [CKRecord]) {
            passTypes = [PassType]()

            for record in records {
                let newPassType = PassType(passTypeRecord : record)
                self.passTypes.append(newPassType)
            }
            successHandler()
        }

        func errorHandler(_ error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createPassTypeLists, errorHandler: errorHandler)
    }
}
