//
//  PassActivity.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/26/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class PassActivity: Activity {
    var passesAdded : Int
    var price : String

    init(clientId: CKRecord.ID, date: Date, passType: PassType) {
        self.passesAdded = passType.passCount
        self.price = String(describing: passType.price)
        super.init(className: "PassActivity", clientId: clientId, date: date)
    }

    override init(activityRecord: CKRecord!) {
        self.passesAdded = activityRecord.object(forKey: "passesAdded") as! Int
        self.price = activityRecord.object(forKey: "price") as! String
        super.init(activityRecord: activityRecord)
    }

    override open func save() {
        record!.setObject(self.passesAdded as CKRecordValue?, forKey: "passesAdded")
        record!.setObject(self.price as CKRecordValue?, forKey: "price")

        super.save()
    }
}
