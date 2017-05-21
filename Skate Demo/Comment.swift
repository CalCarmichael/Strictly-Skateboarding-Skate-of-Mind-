//
//  Comment.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 19/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation

class Comment {
    
    var commentText: String?
    var uid: String?
    
}

extension Comment {
    
    //Instance method put into load posts
    
    static func transformComment(dict: [String: Any]) -> Comment {
        
        let comment = Comment()
        
        comment.commentText = dict["commentText"] as? String
        
        comment.uid = dict["uid"] as? String
        
        return comment
    }
    
       
}
