//
//  InviteViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 15/05/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        loadUsers()
        
        
        
    }
    
 
    
    
    
    func loadUsers() {
        
        Api.User.observeLoadUsers { (user) in
            
            self.users.append(user)
            self.tableView.reloadData()
            
        }
            
            
            
    }

}

extension InviteViewController: UITableViewDataSource {
    
    //Rows in table view - returning users
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Reuses the cells shown rather than uploading all of them at once
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell", for: indexPath) as! InviteTableViewCell
        
        let user = users[indexPath.row]
        cell.user = user
        
        
        return cell
        
    }
    
}
