//
//  LocalTweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Augusto on 1/4/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreData


extension LocalTweet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalTweet> {
        return NSFetchRequest<LocalTweet>(entityName: "LocalTweet");
    }

    @NSManaged public var unique: String?
    @NSManaged public var text: String?
    @NSManaged public var mentions: NSSet?
    @NSManaged public var user: LocalTwitterUser?

}

// MARK: Generated accessors for mentions
extension LocalTweet {

    @objc(addMentionsObject:)
    @NSManaged public func addToMentions(_ value: LocalMention)

    @objc(removeMentionsObject:)
    @NSManaged public func removeFromMentions(_ value: LocalMention)

    @objc(addMentions:)
    @NSManaged public func addToMentions(_ values: NSSet)

    @objc(removeMentions:)
    @NSManaged public func removeFromMentions(_ values: NSSet)

}
