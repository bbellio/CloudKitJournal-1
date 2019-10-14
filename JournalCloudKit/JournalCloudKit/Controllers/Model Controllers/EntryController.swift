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
    
    // Update
    func update(entry: Entry, title: String, bodyText: String, timestamp: Date) {
        
    }
    
    // Delete
    func delete(entry: Entry, completion: @escaping (_ success: Bool) -> Void) {
        privateCloudDatabase.delete(withRecordID: entry.ckRecord) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
//            guard let recordID = recordID else { completion(false) ; return }
//
//            let deletedEntry = Entry(title: entry.title, bodyText: entry.bodyText, timestamp: entry.timestamp, ckRecord: recordID)
//            guard let entryIndex = self.entries.firstIndex(of: deletedEntry) else { return }
//            self.entries.remove(at: entryIndex)
        }
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
