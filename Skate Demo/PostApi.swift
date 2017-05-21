//
//  PostApi.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 19/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

//Api for the post method and getting posts from the database

class PostApi {
    
    var REF_POSTS = FIRDatabase.database().reference().child("posts")
    
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let dict = snapshot.value as? [String: Any] {
                
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                
                completion(newPost)
                
            }
        }
    }
    
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        
        REF_POSTS.child(id).observeSingleEvent(of: FIRDataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
                
            }
        })
        
    }
    
    func observeLikeCount(withPostId id: String, completion: @escaping (Int) -> Void) {
        
        REF_POSTS.child(id).observe(.childChanged, with: {
            snapshot in
            
            if let value = snapshot.value as? Int {
                
                completion(value)
                
            }
        })
        
    }
    
    func observePopularPosts(completion: @escaping (Post) -> Void) {
        
        //Explore post data sorted on like count - the higher likes the highers its up
        
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            
            snapshot in
            
       //For Loop
            
            //Convert entire array into array of Firebase snapshots
            
            let arraySnapshot = (snapshot.children.allObjects as! [FIRDataSnapshot]).reversed()
            
            arraySnapshot.forEach({ (child) in
                
                if let dict = child.value as? [String : Any] {
                    
                    let post = Post.transformPostPhoto(dict: dict, key: child.key)
                    
                    completion(post)
                    
                }
                
            })
            
        })
        
    }
    
    //Get the current post data on database, increase or decrease like data then push change to database
    
    func incrementLikes(postId: String, onSuccess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        let postRef = Api.Post.REF_POSTS.child(postId)
        
        postRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            if var post = currentData.value as? [String : AnyObject], let uid = Api.User.CURRENT_USER?.uid {
                
                print("value 1: \(currentData.value)")
                
                var likes: Dictionary<String, Bool>
                
                likes = post["likes"] as? [String : Bool] ?? [:]
                
                var likeCount = post["likeCount"] as? Int ?? 0
                
                if let _ = likes[uid] {
                    
                    // Unstar the post and remove self from stars
                    likeCount -= 1
                    
                    likes.removeValue(forKey: uid)
                    
                } else {
                    
                    // Star the post and add self to stars
                    
                    likeCount += 1
                    
                    likes[uid] = true
                    
                }
                
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post .transformPostPhoto(dict: dict, key: snapshot!.key)
                
                onSuccess(post)
                
            }
        }
        
    }
    
}
