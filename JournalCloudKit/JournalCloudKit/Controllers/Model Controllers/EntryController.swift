//
//  EntryController.swift
//  JournalCloudKit
//
//  Created by Bethany Wride on 10/14/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    // MARK: - Global variables
    var entries: [Entry] = []
    static let sharedInstance = EntryController()
    let privateCloudDatabase = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD
    // Create
    func createEntry(with title: String, bodyText: String, completion: @escaping (_ success: Bool) -> Void) {
        let newEntry = Entry(title: title, bodyText: bodyText)
        save(entry: newEntry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    } // End of function
    
    // Update in the Cloud
    func update(entry: Entry, completion: @escaping (_ success: Bool) -> Void) {
        let recordToUpdate = CKRecord(entry: entry)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard recordToUpdate == records?.first else {
                print("Unexpected record was updated")
                completion(false)
                return
            }
            print("Updated \(recordToUpdate.recordID) successfully")
            completion(true)
        }
        privateCloudDatabase.add(operation)
    }
    
    // Delete
    func delete(entry: Entry, completion: @escaping (_ success: Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [entry.ckRecord])
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = {_, recordIDs, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard entry.ckRecord == recordIDs?.first else {
                print("Unexpected recordID deleted")
                completion(false)
                return
            }
            print("Successfully deleted Entry from CloudKit")
            completion(true)
        }
        privateCloudDatabase.add(operation)
    }
    
 // MARK: - Save and Fetch
    func fetchEntries(completion: @escaping (_ success: Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.recordTypeKey, predicate: predicate)
        privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let unwrappedRecords = records else { completion(false) ; return }
            let entriesArray = unwrappedRecords.compactMap( {Entry(ckRecord: $0)})
            self.entries = entriesArray
            print("Fetched entries array successfully")
            completion(true)
        }
    } // End of function

    func save(entry: Entry, completion: @escaping (_ success: Bool) -> Void) {
        let entryRecord = CKRecord(entry: entry)
        privateCloudDatabase.save(entryRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let unwrappedRecord = record,
                let savedEntry = Entry(ckRecord: unwrappedRecord)
                else { completion(false) ; return }
            self.entries.append(savedEntry)
            print("Saved entry successfully")
            completion(true)
        } 
    } // End of function
} // End of class
