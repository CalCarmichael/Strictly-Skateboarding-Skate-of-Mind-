//
//  SearchViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 22/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchBar = UISearchBar()
    var users: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
   
        //Search Bar UI
        
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search Skaters!"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        
        searchUser()
        
    }
    
    func searchUser() {
        
        if let searchText = searchBar.text?.lowercased() {
            
            //Remove old search results so only new searched users shown
            
            self.users.removeAll()
            self.tableView.reloadData()
            
            Api.User.queryUsers(withText: searchText, completion: { (user) in
                
                //Check if queried user if followed/unfollowed by current user
                
                self.isFollowing(userId: user.id!, completed: { (value) in
                    
                    user.isFollowing = value
                    
                    self.users.append(user)
                    
                    self.tableView.reloadData()
                    
                })
                
            })
            
        }
        
    }
        
    //Are the users followed/unfollowed by current user
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        
        Api.Follow.isFollowing(userId: userId, completed: completed)
        
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    
    if segue.identifier == "Search_ProfileSegue" {
        let profileVC = segue.destination as! ProfileUserViewController
        let userId = sender as! String
        profileVC.userId = userId
        
        profileVC.delegate = self

        
    }
    
    }
    
}


extension SearchViewController: UISearchBarDelegate {
    
    //Handle search requests after search button clicked (self explanitory)
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchUser()
        
    }
    
    //Register what users type in so I can query it later on
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUser()
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    //Rows in table view - returning users
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Reuses the cells shown rather than uploading all of them at once
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverUserTableViewCell", for: indexPath) as! DiscoverUserTableViewCell
        
        //Extracting the user object from user array
        
        let user = users[indexPath.row]
        
        cell.user = user
        
        cell.delegate = self
        
        return cell
    }
    
}

extension SearchViewController: DiscoverUserTableViewCellDelegate  {
    
    func goToProfileUserVC(userId: String) {
        
        performSegue(withIdentifier: "Search_ProfileSegue", sender: userId)
        
    }
    
}

extension SearchViewController: ProfileHeaderCollectionReusableViewDelegate {
    
    func updateFollowButton(forUser user: User) {
        
        // for loop asking is this person the input user (u = user)
        
        for u in self.users {
            
            // comapre id and if they match its correct user
            
            if u.id == user.id {
                
                //then update following state in view controller
                
                u.isFollowing = user.isFollowing
                
                self.tableView.reloadData()
                
            }
            
            
            
        }
}

}
