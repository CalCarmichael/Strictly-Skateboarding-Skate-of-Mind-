//
//  userPostApi.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 20/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

class userPostApi {
    
    var REF_USER_POSTS = FIRDatabase.database().reference().child("userPosts")
    
    func getUserPosts(userId: String, completion: @escaping (String) -> Void) {
        
            // Access posts database - against user id - then child added to check if posts been shared
        
        REF_USER_POSTS.child(userId).observe(.childAdded, with: {
            
            snapshot in
            
            completion(snapshot.key)
            
        })
        
    }
    
    func getCountUserPosts(userId: String, completion: @escaping (Int) -> Void) {
        
        REF_USER_POSTS.child(userId).observe(.value, with: {
            
            snapshot in
            
            let count = Int(snapshot.childrenCount)
            
            completion(count)
            
        })
        
    }
    
}
