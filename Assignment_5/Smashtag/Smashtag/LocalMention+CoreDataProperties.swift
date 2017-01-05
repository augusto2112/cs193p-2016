//
//  LocalMention+CoreDataProperties.swift
//  Smashtag
//
//  Created by Augusto on 1/5/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreData


extension LocalMention {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalMention> {
        return NSFetchRequest<LocalMention>(entityName: "LocalMention");
    }

    @NSManaged public var text: String?
    @NSManaged public var numberOfMentions: Int64
    @NSManaged public var tweets: NSSet?

}

// MARK: Generated accessors for tweets
extension LocalMention {

    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: LocalTweet)

    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: LocalTweet)

    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)

    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)

}
