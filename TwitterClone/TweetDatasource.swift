//
//  TweetDatasource.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class TweetDatasource: Datasource {
    var tweets = [Tweet]()
    
    func convertToTweets(tweetSnapshot: FIRDataSnapshot) {
        
        let currTweet = tweetSnapshot
        let name = currTweet.childSnapshot(forPath: "name").value as? String
        let username = currTweet.childSnapshot(forPath: "username").value as? String
        let userId = currTweet.childSnapshot(forPath: "userId").value as? String
        let profilePicUrl = currTweet.childSnapshot(forPath: "userProfilePicDownloadUrl").value as? String
        let tweet =  currTweet.childSnapshot(forPath: "tweet").value as? String
        let date =  currTweet.childSnapshot(forPath: "tweetDate").value as? String
        let tweetId = currTweet.childSnapshot(forPath: "tweetId").value as? String

        let currentTweet = Tweet(userId: userId!, username: username!, name: name!, tweet: tweet!, userProfilePicDownloadUrl: profilePicUrl!, tweetDate: date!, tweetId: tweetId!)
        tweets.append(currentTweet)
        
    }

    
    override func numberOfItems(_ section: Int) -> Int {
        return tweets.count
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return tweets[indexPath.item]
    }
    
}
