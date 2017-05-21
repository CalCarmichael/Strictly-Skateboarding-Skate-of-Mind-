//
//  UserApi.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 19/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

class UserApi {
    
    var REF_USERS = FIRDatabase.database().reference().child("users")
    
    func observeUserByUsername (username: String, completion: @escaping (User) -> Void ) {
        
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            
            snapshot in
            
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
                
            }
            
        })
    }
    
    func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeCurrentUser(completion: @escaping (User) -> Void) {
     
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return
        }
        
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
                
            }
            
        })
        
    }
    
    
    //Loading users in withinn Discover User
    
    func observeLoadUsers(completion: @escaping (User) -> Void) {
        
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                
                //Only return user in following page who arent current user
                
                if user.id! != Api.User.CURRENT_USER?.uid {
                    
                    completion(user)
                    
                }
                
            }
        })
        
    }
    
    //Usernames responding to search bar will gather together
    
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        
        //Query ending constrains the results + u{f8ff} guarantess that any word with text at beginning will rank lower than it + queryLimited displays first 10 people on database
        
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            
            snapshot in
            
            //Loop through the array
            
            snapshot.children.forEach({ (s) in
                
                let child = s as! FIRDataSnapshot
                
                if let dict = child.value as? [String : Any] {
                    
                    let user = User.transformUser(dict: dict, key: child.key)
                    
                    
                        
                        completion(user)
                        
                        
                    }
                    
                })
                
        })
                    
        
    }
    
    var CURRENT_USER: FIRUser? {
        if let currentUser = FIRAuth.auth()?.currentUser {
            return currentUser
        }
        
        return nil
        
    }
    
    //Query reference to the user on the database 
    
    var REF_CURRENT_USER: FIRDatabaseReference? {
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
        
    }

}
