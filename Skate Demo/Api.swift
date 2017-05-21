//
//  Api.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 19/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation

struct Api {
    
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var userPosts = userPostApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var Hashtag = HashtagApi()
    
}
