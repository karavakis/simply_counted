//
//  PassCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/3/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class PassCollection: CloudKitContainer {

    //Make an array for each month
    var passActivities = [String:[PassActivity]]()

    override init() {
        super.init()
    }

    open func load(_ successHandler:@escaping (()->Void)) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let query = CKQuery(recordType: "PassActivity", predicate: predicate)
        query.sortDescriptors = [sort]

        func createClassList(_ records: [CKRecord]) {
            passActivities = [String:[PassActivity]]()

            for record in records {
                let newPassActivity = PassActivity(activityRecord : record)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM yyyy"
                let month = dateFormatter.string(from: newPassActivity.date)
                if(self.passActivities[month] != nil) {
                    self.passActivities[month]!.append(newPassActivity)
                }
                else {
                    self.passActivities[month] = [PassActivity]()
                    self.passActivities[month]!.append(newPassActivity)
                }
            }
            successHandler()
        }

        func errorHandler(_ error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createClassList, errorHandler: errorHandler)
    }
}
