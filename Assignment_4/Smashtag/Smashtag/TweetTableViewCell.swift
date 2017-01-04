//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.attributedText = generateTextFrom(tweet)
            if tweetTextLabel?.attributedText != nil  {
                for _ in tweet.media {
                    let temp = NSMutableAttributedString(attributedString: tweetTextLabel.attributedText!)
                    temp.append(NSAttributedString(string:(" 📷")))
                    tweetTextLabel.attributedText = temp
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                let queue = DispatchQueue(label: "profile image fetcher", qos: .userInitiated)
                queue.async { [weak weakSelf = self] in
                    do {
                        let imageData = try Data(contentsOf: profileImageURL) // blocks main thread!
                        DispatchQueue.main.async {
                            weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData)
                        }
                    } catch let exception {
                        fatalError("this error " + exception.localizedDescription)
                    }
                }
            }
            
            let formatter = DateFormatter()
            if Date().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created)
        }

    }
    
    fileprivate func generateTextFrom(_ tweet: Tweet) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: tweet.text)
        for mention in tweet.userMentions {
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: mention.nsrange)
            attributedText.addAttribute(NSFontAttributeName, value: UIFont(name: "Chalkduster", size: tweetTextLabel.font.pointSize)!, range: mention.nsrange) // Im a UI designer now LOL
        }
        for hashtag in tweet.hashtags {
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: hashtag.nsrange)
            attributedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.green, range: hashtag.nsrange)
        }
        for url in tweet.urls {
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: url.nsrange)
            attributedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.orange, range: url.nsrange)
        }
        return attributedText
    }
    
    
}




























