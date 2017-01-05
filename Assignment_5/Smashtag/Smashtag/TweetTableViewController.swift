//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    // MARK: Model
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext


    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
        
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
            SearchManager.addToRecentlySearched(searchText!)
        }
    }
    
    // MARK: Fetching Tweets
    
    fileprivate var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText, !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    fileprivate var lastTwitterRequest: Twitter.Request?

    fileprivate func searchForTweets()
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count - section)"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
    
        return cell
    }
    
    // MARK: Constants
    
    fileprivate struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    // MARK: Outlets

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show tweet detail" {
            if let vc = segue.destination as? TweetDetailTableViewController, let cell = sender as? TweetTableViewCell {
                vc.setup(cell.tweet!)
            }
        }

    }
    
    // MARK: Core data
    
    fileprivate func updateDatabase(_ newTweets: [Tweet]) {
        managedObjectContext?.perform {
            for twitterInfo in newTweets {
                _ = LocalTweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            try? self.managedObjectContext?.save()
        }
        printDatabaseStatistics()
    }
    
    fileprivate func printDatabaseStatistics() {
        managedObjectContext?.perform {
            if let results = try? self.managedObjectContext!.fetch(NSFetchRequest(entityName: "LocalTwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            // a more efficient way to count objects ...
            if let tweetCount = try? self.managedObjectContext!.count(for: NSFetchRequest(entityName: "LocalTweet")) {
                print("\(tweetCount) Tweets")
            }
            if let mentions = try? self.managedObjectContext!.count(for: NSFetchRequest(entityName: "LocalMention")) {
                print("\(mentions) Mentions")
            }
            
            let request = NSFetchRequest<LocalMention>(entityName: "LocalMention")
            request.predicate = NSPredicate(format: "text MATCHES [c] %@", "#trump")
            
            if let mention = try? self.managedObjectContext!.fetch(request).first {
                
                for tweet in mention!.tweets! {
                    print((tweet as! LocalTweet).text)
                }
                print("Count: \(mention!.tweets!.count)")
            }
            
            let request2 = NSFetchRequest<LocalMention>(entityName: "LocalMention")
            request2.predicate = NSPredicate(format: "!(text MATCHES [c] %@)", "#trump")
            
            if let mention = try? self.managedObjectContext!.fetch(request2).first {
                
                for tweet in mention!.tweets! {
                    print((tweet as! LocalTweet).text)
                }
                print("Count: \(mention!.tweets!.count)")
            }


//            if let results = try? self.managedObjectContext!.fetch(NSFetchRequest(entityName: "LocalTweet")) {
//                for tweet in (results as? [LocalTweet])! {
//                    for mention in Array(tweet.mentions!) as! [LocalMention] {
//                        print(mention.text)
//                    }
//                }
//            }
        }
    }

    
}


































