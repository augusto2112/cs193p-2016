//
//  LocalTwitterUser+CoreDataClass.swift
//  Smashtag
//
//  Created by Augusto on 1/4/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

public class LocalTwitterUser: NSManagedObject {
    class func tweeterUserWithTwitterInfo(_ twitterInfo: User,
                                    inManagedObjectContext context: NSManagedObjectContext) -> LocalTwitterUser? {
        let request = NSFetchRequest<LocalTwitterUser>.init(entityName: "LocalTwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        
        if let twitterUser = (try? context.fetch(request))?.first {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObject(forEntityName: "LocalTwitterUser", into: context) as? LocalTwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            return twitterUser
        }
        
        return nil
    }

    
}
