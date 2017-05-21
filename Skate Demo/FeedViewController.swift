//
//  FeedViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 06/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        loadPosts()
        
        
    }
    
    //Retrieving the posts from the database with child added - updates only what we want not everything
    
    func loadPosts() {
        
        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
            
                        guard let postUid = post.uid else {
                            return
                        }
            
                        self.getUser(uid: postUid, completed: {
            
                            self.posts.insert(post, at: 0)
            
                            self.tableView.reloadData()
                        
                        })
                    }
        
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
            
                self.posts = self.posts.filter { $0.id != post.id }
            
                self.users = self.users.filter { $0.id != post.uid }
                
                self.tableView.reloadData()
            }
        
    }
    

    
    func getUser(uid: String, completed: @escaping () -> Void) {
        
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        
        if segue.identifier == "Feed_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }
        
        
    }
    

}





extension FeedViewController: UITableViewDataSource {
    
    //Rows in table view - returning posts
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return posts.count
        
    }
    
    //Customise rows
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Reuses the cells shown rather than uploading all of them at once
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! FeedTableViewCell
        
        //Posting the user information from Folder Views - FeedTableViewCell
        
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
    
}

extension FeedViewController: FeedTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Feed_HashtagSegue", sender: tag)
    }
    
}


