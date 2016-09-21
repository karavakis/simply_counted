//
//  PassType.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/2/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class PassType: CloudKitRecord {
    var passCount: Int
    var price: NSDecimalNumber

    init(passCount: Int, price: NSDecimalNumber) {
        self.passCount = passCount
        self.price = price

        super.init()
        self.record = CKRecord(recordType: "PassType")
    }

    init(passTypeRecord: CKRecord!) {
        self.passCount = passTypeRecord.objectForKey("passCount") as! Int
        let priceString = passTypeRecord.objectForKey("price") as! String
        self.price = NSDecimalNumber(string: priceString)

        super.init()
        self.record = passTypeRecord
    }

    public func save(successHandler:(()->Void)?) {
        record!.setObject(self.passCount, forKey: "passCount")
        let priceString = String(self.price)
        record!.setObject(priceString, forKey: "price")
        self.saveRecord(successHandler, errorHandler: nil)
    }
}
