//
//  Search.swift
//  Smashtag
//
//  Created by Augusto on 12/30/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation

class SearchManager {
    static let defaults = UserDefaults.standard

    class func addToRecentlySearched(search: String) {
        var searches = defaults.object(forKey: tweetSearches) as? [String]
        if searches != nil {
            if searches!.contains(search) {
                searches!.remove(at: searches!.index(of: search)!)
            }
            searches!.insert(search, at: 0)
        } else {
            searches = [search]
        }
        
        if searches!.count > 100 {
            searches!.removeLast()
        }
        
        defaults.set(searches, forKey: tweetSearches)
        defaults.synchronize()
    }
    
    class func getSearches() -> [String] {
        return defaults.array(forKey: tweetSearches) as? [String] ?? []
    }
    
    
    class func remove(at index: Int) {
        if var searches = defaults.object(forKey: tweetSearches) as? [String] {
            searches.remove(at: index)
            defaults.set(searches, forKey: tweetSearches)
            defaults.synchronize()
        }
    }
    
    class func remove(search: String) {
        if var searches = defaults.object(forKey: tweetSearches) as? [String] {
            if let index = searches.index(of: search) {
                searches.remove(at: index)
                defaults.set(searches, forKey: tweetSearches)
                defaults.synchronize()
            }
        }
    }
}
