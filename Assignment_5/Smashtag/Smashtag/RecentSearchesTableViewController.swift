//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Augusto on 12/30/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class RecentSearchesTableViewController: UITableViewController {
    
    fileprivate var recentSearches = [String]()
    
    // MARK: - Constants
    
    fileprivate struct Storyboard {
        static let searchCell = "searchCell"
        static let searchSegue = "search"
    }
    
    fileprivate func reloadSearches() {
        let searches = SearchManager.getSearches()
        if searches != recentSearches {
            recentSearches = searches
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSearches()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.searchCell, for: indexPath)

        cell.textLabel?.text = recentSearches[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            SearchManager.remove(at: indexPath.row)
            reloadSearches()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        SearchManager.moveObject(fromIndexPath.row, to: to.row)
    }

    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return SearchManager.isValid(indexPath.row)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.searchSegue {
            if let vc = segue.destination as? TweetTableViewController, let cell = sender as? UITableViewCell {
                vc.searchText = cell.textLabel?.text
            }
        }
    }

}























