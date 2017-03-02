//
//  LikeTweet.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/14/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct LikeTweet {
    let userId: String
    let tweetId: String
    
    func toAnyObject() -> Any {
        return [
            "userId": userId,
            "tweetId": tweetId
        ]
    }
}
