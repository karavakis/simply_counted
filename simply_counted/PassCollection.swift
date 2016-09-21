//
//  PassCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/3/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class PassCollection: CloudKitContainer {

    //Make an array for each month
    var passActivities = [String:[PassActivity]]()

    override init() {
        super.init()
    }

    public func load(successHandler:(()->Void)) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let query = CKQuery(recordType: "PassActivity", predicate: predicate)
        query.sortDescriptors = [sort]

        func createClassList(records: [CKRecord]) {
            passActivities = [String:[PassActivity]]()

            for record in records {
                let newPassActivity = PassActivity(activityRecord : record)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMMM yyyy"
                let month = dateFormatter.stringFromDate(newPassActivity.date)
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

        func errorHandler(error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createClassList, errorHandler: errorHandler)
    }
}