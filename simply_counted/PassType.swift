//
//  PassType.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class PassType: CloudKitRecord {
    var passCount: Int
    var price: String

    init(passCount: Int, price: String) {
        self.passCount = passCount
        self.price = price

        super.init()
        self.record = CKRecord(recordType: "PassType")
    }

    init(passTypeRecord: CKRecord!) {
        self.passCount = passTypeRecord.object(forKey: "passCount") as! Int
        self.price = passTypeRecord.object(forKey: "price") as! String

        super.init()
        self.record = passTypeRecord
    }

    open func save(_ successHandler:(()->Void)?) {
        record!.setObject(self.passCount as CKRecordValue?, forKey: "passCount")
        record!.setObject(self.price as CKRecordValue?, forKey: "price")
        self.saveRecord(successHandler, errorHandler: nil)
    }
}
