//
//  ClassDate.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 8/21/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

open class ClassDate: NSObject {

    //Make an array for each month
    var checkIns = [CheckIn]()
    var date : Date

    override init() {
        date = Date()
        super.init()
    }

    init(checkIn: CheckIn) {
        self.date = checkIn.date
        checkIns.append(checkIn)

        super.init()
    }

    open func append(_ checkIn: CheckIn) {
        checkIns.append(checkIn)
    }

    open func getCheckInById(_ id: Int) -> CheckIn? {
        return self.checkIns[id]
    }

    open func count() -> Int {
        return self.checkIns.count
    }

}
