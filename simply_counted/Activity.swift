//
//  Activity.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/26/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class Activity: CloudKitRecord {

    var clientReference: CKRecord.Reference?
    var date: Date

    init(className: String, clientId: CKRecord.ID, date: Date) {
        self.clientReference = CKRecord.Reference(recordID: clientId, action: .deleteSelf)
        self.date = date

        super.init()
        self.record = CKRecord(recordType: className)
    }

    init(activityRecord: CKRecord!) {
        self.clientReference = activityRecord.object(forKey: "client") as? CKRecord.Reference
        self.date = activityRecord.object(forKey: "date") as! Date

        super.init()
        self.record = activityRecord
    }

    open func save() {
        record!.setObject(self.clientReference, forKey: "client")
        record!.setObject(self.date as CKRecordValue?, forKey: "date")
        self.saveRecord(nil, errorHandler: nil)
    }
}
