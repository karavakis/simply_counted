//
//  Client.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class Client: CloudKitRecord {

    var name: String
    var passes: Int
    var notes : String
    var activities = [Activity]()
    var lastCheckIn : Date? = nil

    //calculated variables
    var totalCheckIns = 0
    var totalPasses = 0
    var totalPrice : NSDecimalNumber = 0

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
        self.passes -= 1 //TODO: Do we want to let them go into negative passes if they dont have any left?
        self.totalCheckIns += 1

        var insertAt = activities.count
        for (index, activity) in activities.enumerated() {
            if( activity.date.compare(date) == ComparisonResult.orderedAscending) {
                insertAt = index
                break
            }
        }
        self.activities.insert(checkIn, at: insertAt)

        self.updateLastCheckIn()
        self.save(nil)
    }

    func updateLastCheckIn() {
        self.lastCheckIn = nil
        for activity in self.activities {
            if let checkIn = activity as? CheckIn {
                self.lastCheckIn = checkIn.date
                break;
            }
        }
    }

    /**********/
    /* Passes */
    /**********/
    open func addPasses(_ passTypeAdded: PassType) {
        self.passes += passTypeAdded.passCount
        self.totalPasses += passTypeAdded.passCount
        self.totalPrice = self.totalPrice.adding(NSDecimalNumber(string: passTypeAdded.price))
        self.save(nil)
        let passActivity = PassActivity(clientId: self.record!.recordID,
                                        date: Date(),
                                        passType: passTypeAdded)
        passActivity.save()
        self.activities.insert(passActivity, at: 0)
    }

    /***************/
    /* Update Note */
    /***************/
    open func updateNotes(_ notes: String) {
        self.notes = notes
        self.save(nil)
    }

    /**********************/
    /* Update Passes Left */
    /**********************/
    open func updatePassesLeft(_ passesLeft: Int, successHandler:(()->Void)?) {
        self.passes = passesLeft
        self.save(successHandler)
    }

    /*******************/
    /* Remove Activity */
    /*******************/
    func removeActivity(activityIndex: Int) {
        if let passActivity = self.activities[activityIndex] as? PassActivity {
            self.passes -= passActivity.passesAdded
            self.totalPasses -= passActivity.passesAdded
            self.totalPrice = self.totalPrice.subtracting(NSDecimalNumber(string: passActivity.price))
        }
        else {
            self.passes += 1
            self.totalCheckIns -= 1
        }
        self.activities.remove(at: activityIndex)
        updateLastCheckIn()
        self.save(nil)
    }

    /**************/
    /* Activities */
    /**************/
    open func loadActivities(_ successHandler:@escaping (()->Void)) {
        //clear activities
        activities = [Activity]()

        //get check-ins
        let clientReference = CKRecord.Reference(recordID: record!.recordID, action: .deleteSelf)
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
            totalCheckIns = checkInRecords.count

            func passActivitiesLoadSuccess(_ records: [CKRecord]) {
                var passActivityRecords = records
                totalPasses = 0
                totalPrice = 0

                //Process Activities and Check-ins
                func getNextPassActivity() -> PassActivity? {
                    if let nextPassActivityObject = passActivityRecords.popLast() {
                        let passActivity = PassActivity(activityRecord: nextPassActivityObject)
                        totalPasses += passActivity.passesAdded
                        totalPrice = NSDecimalNumber(string: passActivity.price).adding(totalPrice)
                        return passActivity
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
            let sort = NSSortDescriptor(key: "date", ascending: true)
            getPassActivitiesQuery.sortDescriptors = [sort]
            self.performQuery(getPassActivitiesQuery, successHandler: passActivitiesLoadSuccess, errorHandler: passActivityErrorHandler)
        }

        self.performQuery(getCheckInsQuery, successHandler: checkInsLoadSuccess, errorHandler: checkInErrorHandler)
    }
}
