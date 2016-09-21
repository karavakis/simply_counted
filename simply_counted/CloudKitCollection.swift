//
//  CloudKitCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/16/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import CloudKit

public class CloudKitContainer: NSObject {
    let container = CKContainer.defaultContainer()
    var privateDatabase: CKDatabase? = nil

    override init() {
        privateDatabase = container.privateCloudDatabase
        super.init()
    }

    func performQuery(query: CKQuery, successHandler:((records: [CKRecord])->Void)?, errorHandler:((error: NSError)->Void)?) {

        self.privateDatabase!.performQuery(query, inZoneWithID: nil) { records, error in
            dispatch_async(dispatch_get_main_queue(), {
                if let err = error {
                    if let errorHandler = errorHandler {
                        errorHandler(error: err)
                    }
                } else {
                    if let successHandler = successHandler {
                        if let records = records {
                            successHandler(records: records)
                        }
                    }
                }
            })
        }
    }
}
