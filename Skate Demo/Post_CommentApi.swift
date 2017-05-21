//
//  Post_CommentApi.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 19/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import Firebase

class Post_CommentApi {
    
    var REF_POST_COMMENTS = FIRDatabase.database().reference().child("post-comments")
    
}
