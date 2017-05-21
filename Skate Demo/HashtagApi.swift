//
//  HashtagApi.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 13/05/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

class HashtagApi {
    
    var REF_HASHTAG = FIRDatabase.database().reference().child("hashtags")
    
    func fetchPostHashtag(withTag tag: String, completion: @escaping (String) -> Void) {
    
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            
            snapshot in
            
            completion(snapshot.key)
            
        })
    
    }

}
