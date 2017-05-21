//
//  HelperService.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 21/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import ProgressHUD
import Firebase

class HelperService {
    
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        
        //If user shares video - video data sent to storage
        
        if let videoUrl = videoUrl {
            
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    
                    sendDataToFirebase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
                    
                })
                
            })
            
           // self.sendatatodatabase
            
        } else {
            
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                
                self.sendDataToFirebase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
            
        }
        
       
            
        }
        
        
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        
        let videoIdString = NSUUID().uuidString
        
        let storageRef = FIRStorage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        
        storageRef.putFile(videoUrl, metadata: nil) { (metadata, error) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
                
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(videoUrl)
            }
            
        }

        
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        
        //Creating UniqueID for photos users post
        
        let photoIdString = NSUUID().uuidString
        
        let storageRef = FIRStorage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        
        storageRef.put(data, metadata: nil) { (metadata, error) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
                
            }
            
            if let photoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(photoUrl)
            }

        }
        
    }
    
    
    //Send data to database with unqiue post id
    
    static func sendDataToFirebase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        
        let newPostReference = Api.Post.REF_POSTS.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        
        let currentUserId = currentUser.uid
        
        //For Caption
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            
            if word.hasPrefix("#") {
                
            word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
            
            let newHashtagRef = Api.Hashtag.REF_HASHTAG.child(word.lowercased())
                
                newHashtagRef.updateChildValues([newPostId: true])
            
            }
        
            
        }
        
        //Timestamping uploaded photos
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        print(timestamp)
        
        
        //Dict to hold all data we need to database
        
        var dict = ["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio, "timestamp": timestamp] as [String : Any]
        
        //If videoUrl is nil otherwise add it to dictionary
        
        if let videoUrl = videoUrl {
            
            dict["videoUrl"] = videoUrl
            
        }
        
        //Dict posted in this new post reference now
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            //Once post registered store it in feed corresponding to current user. newPostId creates new node
            
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(true)
            
            let userPostRef = Api.userPosts.REF_USER_POSTS.child(currentUserId).child(newPostId)
            userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            ProgressHUD.showSuccess("Success")
            
            onSuccess()
            
        })
        
        
    }
    
}
