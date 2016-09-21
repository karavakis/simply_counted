//
//  CheckIn.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/19/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CloudKit

public class CheckIn: Activity {
    
    init(clientId: CKRecordID, date: NSDate) {
        super.init(className: "CheckIn", clientId: clientId, date: date)
    }

    override init(activityRecord: CKRecord!) {
        super.init(activityRecord: activityRecord)
    }
}