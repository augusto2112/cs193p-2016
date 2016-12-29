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
    var tweet: Tweet?
    
    fileprivate var mapping = [Int: [AnyObject]]()
    
    fileprivate var sectionTitles = [String]()
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return !(mapping[section] ?? []).isEmpty ? sectionTitles[section] : nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapping[section]?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        guard tweet != nil else {
            return cell
        }
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.pictureView.contentMode = .scaleAspectFit
                imageCell.pictureURL = tweet?.media[indexPath.row].url
            }
        case 1, 2, 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "mentionCell", for: indexPath)
            cell.textLabel?.text = mapping[indexPath.section]![indexPath.row].keyword
        default:
            fatalError("Cell has to be one of the above")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && tweet != nil {
            let media = tweet?.media[indexPath.row]
            return tableView.frame.width / CGFloat(media!.aspectRatio)
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && tweet != nil {
            let url = URL(string: mapping[indexPath.section]![indexPath.row].keyword!)
            if url != nil && UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        if tweet != nil {
            mapping = [0: tweet!.media, 1: tweet!.userMentions, 2: tweet!.hashtags, 3: tweet!.urls]
            sectionTitles.append(contentsOf: ["Media", "Mentions", "Hashtags", "URLs"])
            print("here??")

        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show more" {
            if let vc = segue.destination as? TweetTableViewController, let cell = sender as? UITableViewCell {
                let index = tableView.indexPath(for: cell)
                vc.searchText = mapping[index!.section]![index!.row].keyword
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)
            if index?.section == 3 {
                return false
            }
        }
        return true
    }

}




