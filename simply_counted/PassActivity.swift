//
//  PassActivity.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/26/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class PassActivity: Activity {
    var passesAdded : Int
    var price : String

    init(clientId: CKRecordID, date: NSDate, passType: PassType) {
        self.passesAdded = passType.passCount
        self.price = String(passType.price)
        super.init(className: "PassActivity", clientId: clientId, date: date)
    }

    override init(activityRecord: CKRecord!) {
        self.passesAdded = activityRecord.objectForKey("passesAdded") as! Int
        self.price = activityRecord.objectForKey("price") as! String
        super.init(activityRecord: activityRecord)
    }

    override public func save() {
        record!.setObject(self.passesAdded, forKey: "passesAdded")
        record!.setObject(self.price, forKey: "price")

        super.save()
    }
}