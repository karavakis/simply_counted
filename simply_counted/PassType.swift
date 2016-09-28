//
//  PassType.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

open class PassType: CloudKitRecord {
    var passCount: Int
    var price: NSDecimalNumber

    init(passCount: Int, price: NSDecimalNumber) {
        self.passCount = passCount
        self.price = price

        super.init()
        self.record = CKRecord(recordType: "PassType")
    }

    init(passTypeRecord: CKRecord!) {
        self.passCount = passTypeRecord.object(forKey: "passCount") as! Int
        let priceString = passTypeRecord.object(forKey: "price") as! String
        self.price = NSDecimalNumber(string: priceString)

        super.init()
        self.record = passTypeRecord
    }

    open func save(_ successHandler:(()->Void)?) {
        record!.setObject(self.passCount as CKRecordValue?, forKey: "passCount")
        let priceString = String(describing: self.price)
        record!.setObject(priceString as CKRecordValue?, forKey: "price")
        self.saveRecord(successHandler, errorHandler: nil)
    }
}
