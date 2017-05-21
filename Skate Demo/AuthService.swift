//
//  AuthService.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 04/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    
    
    //Same instance used instead of creating a new one
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            onSuccess()
            
        })
        
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            let uid = user?.uid
            let storageRef = FIRStorage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            storageRef.put(imageData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    return
                    
                }
                
                let profileImageUrl = metadata?.downloadURL()?.absoluteString
                
                self.setUserInformation(profileImageUrl: profileImageUrl!, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                
            })
            
            
            
        })
        
    }
    
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users")
        let newUserReference = userReference.child(uid)
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl])
        onSuccess()
        
        
    }
    
    //If email is changed updating on authentication
    
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        
        Api.User.CURRENT_USER?.updateEmail(email, completion: { (error) in
            if error != nil {
                
                onError(error!.localizedDescription)
                
            } else {
                
                let uid = Api.User.CURRENT_USER?.uid
                
                let storageRef = FIRStorage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
                storageRef.put(imageData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        return
                        
                    }
                    
                    let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    
                    self.updateDatabase(profileImageUrl: profileImageUrl!, username: username, email: email, onSuccess: onSuccess, onError: onError)
                    
                
            
        })
                
            }
        
        
        })

        
    }
    
   static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
        
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                onError(error!.localizedDescription)
                
            } else {
                
                onSuccess()
                
            }
            
        })
        
    }
    
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        do {
            
            try FIRAuth.auth()?.signOut()
            
            onSuccess()
            
        } catch let logoutError {
           onError(logoutError.localizedDescription)
        }
    }
    
}
