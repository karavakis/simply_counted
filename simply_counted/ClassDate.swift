//
//  ClassDate.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

public class ClassDate: NSObject {

    //Make an array for each month
    var checkIns = [CheckIn]()
    var date : NSDate

    override init() {
        date = NSDate()
        super.init()
    }

    init(checkIn: CheckIn) {
        self.date = checkIn.date
        checkIns.append(checkIn)

        super.init()
    }

    public func append(checkIn: CheckIn) {
        checkIns.append(checkIn)
    }

    public func getCheckInById(id: Int) -> CheckIn? {
        return self.checkIns[id]
    }

    public func count() -> Int {
        return self.checkIns.count
    }

}