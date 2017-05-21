//
//  FollowApi.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 21/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

class FollowApi {
    
    var REF_FOLLOWERS = FIRDatabase.database().reference().child("followers")
    
    var REF_FOLLOWING = FIRDatabase.database().reference().child("following")
    
    
 
    
    func followAction(withUser id: String) {
        
        Api.userPosts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if let dict = snapshot.value as? [String: Any] {
                
                for key in dict.keys {
                    
                    //Creates "feed" node and stores key of the post that showed up in news feed of current user
                    
                    FIRDatabase.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).setValue(true)
                }
            }
        })
        
        //Corresponding users - switch when pressing in corresponding list within database
        
       REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(true)
        
       REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(true)
        
    }
    
    func unfollowAction(withUser id: String) {
        
        Api.userPosts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if let dict = snapshot.value as? [String: Any] {
                
                for key in dict.keys {
                    
                    //Removes "feed" node and stores key of the post that showed up in news feed of current user
                    
                    FIRDatabase.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        })
        
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(NSNull())
        
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
        
        
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        
        REF_FOLLOWERS.child(userId).child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
            
            snapshot in
            
            //If null user not in follower list of this user
            
            if let _ = snapshot.value as? NSNull {
                
                completed(false)
                
            } else {
                
                completed(true)
                
            }
            
            
            
        })
        
    }
    
    func getFollowingCount(userId: String, completion: @escaping (Int) -> Void) {
        
        REF_FOLLOWING.child(userId).observe(.value, with: {
            
            snapshot in
            
            let count = Int(snapshot.childrenCount)
            
            completion(count)
            
        })
        
    }
    
    func getFollowerCount(userId: String, completion: @escaping (Int) -> Void) {
        
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            
            snapshot in
            
            let count = Int(snapshot.childrenCount)
            
            completion(count)
            
        })
        
    }
    
}


