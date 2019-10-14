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
    // Read
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
    
    // MARK: - Save and Load
    func save(entry: Entry, completion: @escaping (_ success: Bool) -> Void) {
        let newEntry = Entry(title: entry.title, bodyText: entry.bodyText)
        let entryRecord = CKRecord(entry: newEntry)
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
