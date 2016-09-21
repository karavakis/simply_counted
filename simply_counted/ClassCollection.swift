//
//  ClassCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class ClassCollection: CloudKitContainer {

    //Make an array for each month
    var classDates = [ClassDate]()

    override init() {
        super.init()
    }

    subscript(id:Int) -> ClassDate? {
        return self.classDates[id]
    }

    public func count() -> Int {
        return self.classDates.count
    }

    public func load(successHandler:(()->Void)) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "CheckIn", predicate: predicate)

        func createClassList(records: [CKRecord]) {
            classDates.removeAll()

            for record in records {
                let newCheckIn = CheckIn(activityRecord : record)
                var foundDate = false
                for classDate in self.classDates {
                    if(NSCalendar.currentCalendar().isDate(classDate.date, inSameDayAsDate: newCheckIn.date)) {
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
            self.classDates.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            successHandler()
        }

        func errorHandler(error: NSError) {
            print("Error: \(error) \(error.userInfo)")
        }

        performQuery(query, successHandler: createClassList, errorHandler: errorHandler)
    }
}