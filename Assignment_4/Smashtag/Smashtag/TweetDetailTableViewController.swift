//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Augusto on 12/28/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailTableViewController: UITableViewController {
    
    fileprivate var tweetData = [Int: (title: String, data: [AnyObject])]()
    
    // MARK: - Constants
    
    fileprivate struct Storyboard {
        static let imageCellIdentifier = "imageCell"
        static let mentionCellIdentifier = "mentionCell"
        static let tweetTableViewControllerIdentifier = "show more"
        static let imageViewControllerIdentifier = "show image"
    }
    
    fileprivate struct Section {
        static let media = 0
        static let mentions = 1
        static let hashtags = 2
        static let urls = 3
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweetData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return !(tweetData[section]?.data ?? []).isEmpty ? tweetData[section]!.title : nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData[section]?.data.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case Section.media:
            cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.imageCellIdentifier, for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.pictureURL = (tweetData[indexPath.section]!.data[indexPath.row] as! MediaItem).url
            }
        case Section.mentions, Section.hashtags, Section.urls:
            cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.mentionCellIdentifier, for: indexPath)
            cell.textLabel?.text = tweetData[indexPath.section]!.data[indexPath.row].keyword
        default:
            fatalError("Cell has to be one of the above")
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.media {
            let media = tweetData[indexPath.section]!.data[indexPath.row]
            return tableView.frame.width / CGFloat(media.aspectRatio)
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.urls {
            let url = URL(string: tweetData[indexPath.section]!.data[indexPath.row].keyword!)
            if url != nil && UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - Setup
    
    func setup(_ tweet: Tweet) {
        tweetData = [Section.media: ("Media", tweet.media),
                     Section.mentions: ("Mentions", tweet.userMentions),
                     Section.hashtags: ("Hashtags", tweet.hashtags),
                     Section.urls: ("URLs", tweet.urls)]
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.tweetTableViewControllerIdentifier {
            if let vc = segue.destination as? TweetTableViewController, let cell = sender as? UITableViewCell {
                let index = tableView.indexPath(for: cell)
                vc.searchText = tweetData[index!.section]!.data[index!.row].keyword
            }
        } else if segue.identifier == Storyboard.imageViewControllerIdentifier {
            if let vc = segue.destination as? ImageViewController, let cell = sender as? ImageTableViewCell {
                vc.image = cell.pictureView.image
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)
            if index?.section == Section.urls {
                return false
            }
        }
        return true
    }
    
}




