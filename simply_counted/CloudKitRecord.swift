//
//  CloudKitRecord.swift
//  simply_counted
//
//  Created by Jennifer Karavakis on 9/14/16.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import CloudKit

open class CloudKitRecord: CloudKitContainer {
    var record: CKRecord? = nil

    func saveRecord(_ successHandler:(()->Void)?, errorHandler:((_ error: NSError)->Void)?) {
        privateDatabase!.save(record!, completionHandler: {
            record, error in DispatchQueue.main.async {
                if let err = error {
                    if let errorHandler = errorHandler {
                        errorHandler(err as NSError)
                    }
                } else {
                    self.record = record!
                    if let successHandler = successHandler {
                        successHandler()
                    }
                }
            }
        }) 
    }

    func deleteRecord(_ successHandler:@escaping (()->Void), errorHandler:@escaping ((_ error: NSError)->Void)) {
        privateDatabase!.delete(withRecordID: record!.recordID) {
            record, error in
            DispatchQueue.main.async {
                if let err = error {
                    errorHandler(err as NSError)
                } else {
                    successHandler()
                }
            }
        }
    }
}
