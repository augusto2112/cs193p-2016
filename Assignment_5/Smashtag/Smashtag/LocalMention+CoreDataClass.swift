//
//  LocalMention+CoreDataClass.swift
//  Smashtag
//
//  Created by Augusto on 1/4/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

open class LocalMention: NSManagedObject {
    class func mentionFrom(_ mention: Mention,
                                    inManagedObjectContext context: NSManagedObjectContext) -> LocalMention? {
        let request = NSFetchRequest<LocalMention>.init(entityName: "LocalMention")
        request.predicate = NSPredicate(format: "text MATCHES [c]%@", mention.keyword)
        
        if let localMention = (try? context.fetch(request))?.first {
            localMention.numberOfMentions += 1
            return localMention
        } else if let localMention = NSEntityDescription.insertNewObject(forEntityName: "LocalMention", into: context) as? LocalMention {
            localMention.text = mention.keyword
            localMention.numberOfMentions = 1
            return localMention
        }
        
        return nil
    }

    class func mentionsFrom(_ twitterInfo: Tweet,
                           inManagedObjectContext context: NSManagedObjectContext) -> NSSet {
        var localMentions = Set<LocalMention>()
        for mention in twitterInfo.hashtags + twitterInfo.userMentions {
            if let localMention = mentionFrom(mention, inManagedObjectContext: context) {
                localMentions.insert(localMention)
            }
        }
        return localMentions as NSSet
    }

}

















