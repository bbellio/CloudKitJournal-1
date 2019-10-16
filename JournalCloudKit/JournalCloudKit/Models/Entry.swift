//
//  Entry.swift
//  JournalCloudKit
//
//  Created by Bethany Wride on 10/14/19.
//  Copyright © 2019 Bethany Wride. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - Constant Strings
struct EntryConstants {
    static let titleKey = "title"
    static let bodyKey = "bodyText"
    static let timestampKey = "timestamp"
    static let recordTypeKey = "Entry"
}

// MARK: - Class Declaration

class Entry {
    var title: String
    var bodyText: String
    var timestamp: Date
    let ckRecord: CKRecord.ID
    
    init(title: String, bodyText: String, timestamp: Date = Date(), ckRecord: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.ckRecord = ckRecord
    }
} // End of class

// MARK: - Extensions
extension Entry {
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[EntryConstants.titleKey] as? String,
            let bodyText = ckRecord[EntryConstants.bodyKey] as? String,
            let timestamp = ckRecord[EntryConstants.timestampKey] as? Date
            else { return nil }
        self.init(title: title, bodyText: bodyText, timestamp: timestamp, ckRecord: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(entry: Entry) {
        self.init(recordType: EntryConstants.recordTypeKey, recordID: entry.ckRecord)
        self.setValue(entry.title, forKey: EntryConstants.titleKey)
        self.setValue(entry.bodyText, forKey: EntryConstants.bodyKey)
        self.setValue(entry.timestamp, forKey: EntryConstants.timestampKey)
    }
}

extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        if lhs.title == rhs.title && lhs.bodyText == rhs.bodyText && lhs.ckRecord == rhs.ckRecord { return true }
        return false
    }
}

