//
//  Tweet.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/5/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct Tweet {
    let userId: String
    let username: String
    let name: String
    let tweet: String
    let userProfilePicDownloadUrl: String
    let tweetDate: String
    let tweetId: String
    
    func toAnyObject() -> Any {
        return [
            "userId": userId,
            "username": username,
            "name": name,
            "tweet": tweet,
            "userProfilePicDownloadUrl": userProfilePicDownloadUrl,
            "tweetDate": tweetDate,
            "tweetId": tweetId
        ]
    }

}
