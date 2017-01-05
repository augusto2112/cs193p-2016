//
//  LocalTwitterUser+CoreDataProperties.swift
//  Smashtag
//
//  Created by Augusto on 1/4/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreData


extension LocalTwitterUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalTwitterUser> {
        return NSFetchRequest<LocalTwitterUser>(entityName: "LocalTwitterUser");
    }

    @NSManaged public var name: String?
    @NSManaged public var screenName: String?
    @NSManaged public var tweets: NSSet?

}

// MARK: Generated accessors for tweets
extension LocalTwitterUser {

    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: LocalTweet)

    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: LocalTweet)

    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)

    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)

}
