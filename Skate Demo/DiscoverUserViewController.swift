//
//  DiscoverUserViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 21/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class DiscoverUserViewController: UIViewController {
    
   
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()
        
    }
    
    func loadUsers() {
        
        Api.User.observeLoadUsers { (user) in
            
            self.isFollowing(userId: user.id!, completed: { (value) in
                
                user.isFollowing = value
                
                self.users.append(user)
                
                self.tableView.reloadData()
                
            })
            
            
        }
        
    }
    
    //Use user id input to look at database and see if current user is following user
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        
        Api.Follow.isFollowing(userId: userId, completed: completed)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewingProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
            
            profileVC.delegate = self
        }
        
    }

}

extension DiscoverUserViewController: UITableViewDataSource {
    
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

extension DiscoverUserViewController: DiscoverUserTableViewCellDelegate {
    
    func goToProfileUserVC(userId: String) {
        
        performSegue(withIdentifier: "ViewingProfileSegue", sender: userId)
        
    }
    
}

extension DiscoverUserViewController: ProfileHeaderCollectionReusableViewDelegate {
    
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
