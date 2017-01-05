//
//  LocalTweet+CoreDataClass.swift
//  Smashtag
//
//  Created by Augusto on 1/4/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

open class LocalTweet: NSManagedObject {
    class func tweetWithTwitterInfo(_ twitterInfo: Tweet,
                                    inManagedObjectContext context: NSManagedObjectContext) -> LocalTweet? {
        let request = NSFetchRequest<LocalTweet>(entityName: "LocalTweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.fetch(request))?.first {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObject(forEntityName: "LocalTweet", into: context) as? LocalTweet {
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.user = LocalTwitterUser.tweeterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
            tweet.addToMentions(LocalMention.mentionsFrom(twitterInfo, inManagedObjectContext: context))
            return tweet
        }
        
        return nil
    }
}
