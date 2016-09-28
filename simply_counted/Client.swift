//
//  Client.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class Client: CloudKitRecord {

    var name: String
    var passes: Int
    var notes : String
    var activities = [Activity]()
    var lastCheckIn : Date? = nil

    /****************/
    /* Initializers */
    /****************/
    init(name: String) {
        self.name = name
        self.passes = 0
        self.notes = ""

        super.init()
        self.record = CKRecord(recordType: "Client")
    }

    init(clientRecord: CKRecord!) {
        self.name = clientRecord.object(forKey: "name") as! String
        self.passes = clientRecord.object(forKey: "passes") as! Int
        self.notes = clientRecord.object(forKey: "notes") as! String
        self.lastCheckIn = clientRecord.object(forKey: "lastCheckIn") as? Date

        super.init()
        self.record = clientRecord
    }

    /****************/
    /* DB Functions */
    /****************/
    open func save(_ successHandler:(()->Void)?) {
        record!.setObject(self.name as CKRecordValue?, forKey: "name")
        record!.setObject(self.passes as CKRecordValue?, forKey: "passes")
        record!.setObject(self.notes as CKRecordValue?, forKey: "notes")
        if let lastCheckIn = self.lastCheckIn {
            record!.setObject(lastCheckIn as CKRecordValue?, forKey: "lastCheckIn")
        }

        self.saveRecord(successHandler, errorHandler: nil)
    }

    /*************/
    /* Check-Ins */
    /*************/

    open func checkIn(_ date: Date) {
        let checkIn = CheckIn(clientId: self.record!.recordID, date: date)
        checkIn.save()
        self.activities.insert(checkIn, at: 0)
        self.passes = self.passes - 1
        self.updateLastCheckIn(date)
        self.save(nil)
    }

    func updateLastCheckIn(_ newCheckIn: Date) {
        if let lastCheckIn = self.lastCheckIn {
            if(lastCheckIn.compare(newCheckIn) == ComparisonResult.orderedDescending) {
                //do not update lastCheckIn
                return
            }
        }
        self.lastCheckIn = newCheckIn
    }

    /**********/
    /* Passes */
    /**********/
    open func addPasses(_ passTypeAdded: PassType) {
        self.passes += passTypeAdded.passCount
        self.save(nil)
        let passActivity = PassActivity(clientId: self.record!.recordID,
                                        date: Date(),
                                        passType: passTypeAdded)
        passActivity.save()
        self.activities.insert(passActivity, at: 0)
    }

    /**************/
    /* Activities */
    /**************/
    open func loadActivities(_ successHandler:@escaping (()->Void)) {
        //clear activities
        activities = [Activity]()

        //get check-ins
        let clientReference = CKReference(recordID: record!.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "client == %@", clientReference)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let getCheckInsQuery = CKQuery(recordType: "CheckIn", predicate: predicate)
        getCheckInsQuery.sortDescriptors = [sort]


        func checkInErrorHandler(_ error: NSError) {
            if(error.domain == CKErrorDomain && error.code == 11) {
                checkInsLoadSuccess([])
            }
            else {
                print("Error: \(error) \(error.userInfo)")
            }
        }

        func checkInsLoadSuccess(_ records: [CKRecord]) {
            var checkInRecords = records

            func passActivitiesLoadSuccess(_ records: [CKRecord]) {
                var passActivityRecords = records

                //Process Activities and Check-ins
                func getNextPassActivity() -> PassActivity? {
                    if let nextPassActivityObject = passActivityRecords.popLast() {
                        return PassActivity(activityRecord: nextPassActivityObject)
                    }
                    return nil
                }

                var nextPassActivity = getNextPassActivity()

                for checkInRecord in checkInRecords {
                    let newCheckIn = CheckIn(activityRecord : checkInRecord)

                    //Append any Pass Activity that occurs before this checkIn
                    while(nextPassActivity != nil && nextPassActivity!.date.compare(newCheckIn.date) == ComparisonResult.orderedDescending) {
                        self.activities.append(nextPassActivity!)
                        nextPassActivity = getNextPassActivity()
                    }

                    self.activities.append(newCheckIn)
                }
                while(nextPassActivity != nil) {
                    self.activities.append(nextPassActivity!)
                    nextPassActivity = getNextPassActivity()
                }
                if let lastCheckInRecord = checkInRecords.first {
                    self.lastCheckIn = lastCheckInRecord.object(forKey: "date") as? Date
                }
                successHandler()
            }

            func passActivityErrorHandler(_ error: NSError) {
                if(error.domain == CKErrorDomain && error.code == 11) {
                    passActivitiesLoadSuccess([])
                }
                else {
                    print("Error: \(error) \(error.userInfo)")
                }
            }

            let getPassActivitiesQuery = CKQuery(recordType: "PassActivity", predicate: predicate)
            getPassActivitiesQuery.sortDescriptors = [sort]
            self.performQuery(getPassActivitiesQuery, successHandler: passActivitiesLoadSuccess, errorHandler: passActivityErrorHandler)
        }

        self.performQuery(getCheckInsQuery, successHandler: checkInsLoadSuccess, errorHandler: checkInErrorHandler)
    }
}
