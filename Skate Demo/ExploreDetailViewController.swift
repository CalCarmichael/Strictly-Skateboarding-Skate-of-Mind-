//
//  FeedDetailViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 05/05/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class ExploreDetailViewController: UIViewController {
    
    var postId = ""
    var post = Post()
    var user = User()
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        
       loadSpecificPost()
        
        
    }

    func loadSpecificPost() {
        
        Api.Post.observePost(withId: postId) { (post) in
            
            guard let postUid = post.uid else {
                return
            }
            
            self.getUser(uid: postUid, completed: {
                
                self.post = post
                
                self.tableView.reloadData()
                
            })
            
        }
        
    }
    
    func getUser(uid: String, completed: @escaping () -> Void) {
        
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.user = user 
            completed()
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExploreDetail_CommentVC" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "ExploreDetail_ProfileUserSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        
        if segue.identifier == "ExploreDetail_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }
        
        
    }
    
 
}

extension ExploreDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! FeedTableViewCell
        
        //Posting the user information from Folder Views - FeedTableViewCell
        
        
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
        
    }
    
}

extension ExploreDetailViewController: FeedTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "ExploreDetail_CommentVC", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ExploreDetail_ProfileUserSegue", sender: userId)
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "ExploreDetail_HashtagSegue", sender: tag)
    }
    
}
