//
//  CloudKitRecord.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/14/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import CloudKit

public class CloudKitRecord: CloudKitContainer {
    var record: CKRecord? = nil

    func saveRecord(successHandler:(()->Void)?, errorHandler:((error: NSError)->Void)?) {
        privateDatabase!.saveRecord(record!) {
            record, error in dispatch_async(dispatch_get_main_queue()) {
                if let err = error {
                    if let errorHandler = errorHandler {
                        errorHandler(error: err)
                    }
                } else {
                    self.record = record!
                    if let successHandler = successHandler {
                        successHandler()
                    }
                }
            }
        }
    }

    func deleteRecord(successHandler:(()->Void), errorHandler:((error: NSError)->Void)) {
        privateDatabase!.deleteRecordWithID(record!.recordID) {
            record, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let err = error {
                    errorHandler(error: err)
                } else {
                    successHandler()
                }
            }
        }
    }
}
