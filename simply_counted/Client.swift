//
//  Client.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class Client: CloudKitRecord {

    var name: String
    var passes: Int
    var notes : String
    var activities = [Activity]()
    var lastCheckIn : NSDate? = nil

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
        self.name = clientRecord.objectForKey("name") as! String
        self.passes = clientRecord.objectForKey("passes") as! Int
        self.notes = clientRecord.objectForKey("notes") as! String
        self.lastCheckIn = clientRecord.objectForKey("lastCheckIn") as? NSDate

        super.init()
        self.record = clientRecord
    }

    /****************/
    /* DB Functions */
    /****************/
    public func save(successHandler:(()->Void)?) {
        record!.setObject(self.name, forKey: "name")
        record!.setObject(self.passes, forKey: "passes")
        record!.setObject(self.notes, forKey: "notes")
        if let lastCheckIn = self.lastCheckIn {
            record!.setObject(lastCheckIn, forKey: "lastCheckIn")
        }

        self.saveRecord(successHandler, errorHandler: nil)
    }

    /*************/
    /* Check-Ins */
    /*************/

    public func checkIn(date: NSDate) {
        let checkIn = CheckIn(clientId: self.record!.recordID, date: date)
        checkIn.save()
        self.activities.insert(checkIn, atIndex: 0)
        self.passes = self.passes - 1
        self.updateLastCheckIn(date)
        self.save(nil)
    }

    func updateLastCheckIn(newCheckIn: NSDate) {
        if let lastCheckIn = self.lastCheckIn {
            if(lastCheckIn.compare(newCheckIn) == NSComparisonResult.OrderedDescending) {
                //do not update lastCheckIn
                return
            }
        }
        self.lastCheckIn = newCheckIn
    }

    /**********/
    /* Passes */
    /**********/
    public func addPasses(passTypeAdded: PassType) {
        self.passes += passTypeAdded.passCount
        self.save(nil)
        let passActivity = PassActivity(clientId: self.record!.recordID,
                                        date: NSDate(),
                                        passType: passTypeAdded)
        passActivity.save()
        self.activities.insert(passActivity, atIndex: 0)
    }

    /**************/
    /* Activities */
    /**************/
    public func loadActivities(successHandler:(()->Void)) {
        //clear activities
        activities = [Activity]()

        //get check-ins
        let clientReference = CKReference(recordID: record!.recordID, action: .DeleteSelf)
        let predicate = NSPredicate(format: "client == %@", clientReference)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let getCheckInsQuery = CKQuery(recordType: "CheckIn", predicate: predicate)
        getCheckInsQuery.sortDescriptors = [sort]


        func checkInErrorHandler(error: NSError) {
            if(error.domain == CKErrorDomain && error.code == 11) {
                checkInsLoadSuccess([])
            }
            else {
                print("Error: \(error) \(error.userInfo)")
            }
        }

        func checkInsLoadSuccess(records: [CKRecord]) {
            var checkInRecords = records

            func passActivitiesLoadSuccess(records: [CKRecord]) {
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
                    while(nextPassActivity != nil && nextPassActivity!.date.compare(newCheckIn.date) == NSComparisonResult.OrderedDescending) {
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
                    self.lastCheckIn = lastCheckInRecord.objectForKey("date") as? NSDate
                }
                successHandler()
            }

            func passActivityErrorHandler(error: NSError) {
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