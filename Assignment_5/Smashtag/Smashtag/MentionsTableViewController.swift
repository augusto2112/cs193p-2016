//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Augusto on 1/5/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class MentionsTableViewController: CoreDataTableViewController {
    var searchTerm: String? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate var context: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    
    fileprivate func updateUI() {
        if searchTerm != nil && context != nil {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalMention")
            request.predicate = NSPredicate(format: "any tweets.text contains [c] %@ and numberOfMentions > 1", searchTerm!)
            request.sortDescriptors = [
                NSSortDescriptor(key: "numberOfMentions", ascending: false),
                NSSortDescriptor(key: "text",ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]

            fetchedResultsController = NSFetchedResultsController(
                                                    fetchRequest: request,
                                                     managedObjectContext: context!,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: nil)
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "twitterUserMentions", for: indexPath)
        if let mention = fetchedResultsController?.object(at: indexPath) as? LocalMention {
            var text: String?
            var subtitle: String?
            context?.performAndWait {
                text = mention.text
                subtitle = String(mention.numberOfMentions) + " mentions"
            }
            cell.textLabel?.text = text
            cell.detailTextLabel?.text = subtitle
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
