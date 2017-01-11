//
//  Constants.swift
//  Smashtag
//
//  Created by Augusto on 12/30/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let tweetSearches = "recent tweets"


class Context {    
    class func getContext() -> NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
}

