//
//  ClassCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class ClassCollection: CloudKitContainer {

    //Make an array for each month
    var classDates = [ClassDate]()

    override init() {
        super.init()
    }

    subscript(id:Int) -> ClassDate? {
        return self.classDates[id]
    }

    open func count() -> Int {
        return self.classDates.count
    }

    open func load(_ successHandler:@escaping (()->Void)) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "CheckIn", predicate: predicate)

        func createClassList(_ records: [CKRecord]) {
            classDates.removeAll()

            for record in records {
                let newCheckIn = CheckIn(activityRecord : record)
                var foundDate = false
                for classDate in self.classDates {
                    if(Calendar.current.isDate(classDate.date as Date, inSameDayAs: newCheckIn.date)) {
                        classDate.append(newCheckIn)
                        foundDate = true
                        break
                    }
                }
                if( !foundDate ) {
                    let newClassDate = ClassDate(checkIn: newCheckIn)
                    self.classDates.append(newClassDate)
                }
            }
            self.classDates.sort(by: { $0.date.compare($1.date) == .orderedDescending })
            successHandler()
        }

        func errorHandler(_ error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createClassList, errorHandler: errorHandler)
    }
}
