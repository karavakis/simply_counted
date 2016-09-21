//
//  Activity.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/26/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class Activity: CloudKitRecord {

    var clientReference: CKReference?
    var date: NSDate

    init(className: String, clientId: CKRecordID, date: NSDate) {
        self.clientReference = CKReference(recordID: clientId, action: .DeleteSelf)
        self.date = date

        super.init()
        self.record = CKRecord(recordType: className)
    }

    init(activityRecord: CKRecord!) {
        self.clientReference = activityRecord.objectForKey("client") as? CKReference
        self.date = activityRecord.objectForKey("date") as! NSDate

        super.init()
        self.record = activityRecord
    }

    public func save() {
        record!.setObject(self.clientReference, forKey: "client")
        record!.setObject(self.date, forKey: "date")
        self.saveRecord(nil, errorHandler: nil)
    }
}