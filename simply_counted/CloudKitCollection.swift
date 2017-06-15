//
//  CloudKitCollection.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/16/16.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import CloudKit

open class CloudKitContainer: NSObject {
    let container = CKContainer.default()
    var privateDatabase: CKDatabase? = nil

    override init() {
        privateDatabase = container.privateCloudDatabase
        super.init()
    }

    func performQuery(_ query: CKQuery, successHandler:((_ records: [CKRecord])->Void)?, errorHandler:((_ error: NSError)->Void)?) {

        self.privateDatabase!.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    if let errorHandler = errorHandler {
                        errorHandler(err as NSError)
                    }
                } else {
                    if let successHandler = successHandler {
                        if let records = records {
                            successHandler(records)
                        }
                    }
                }
            })
        }
    }
}
