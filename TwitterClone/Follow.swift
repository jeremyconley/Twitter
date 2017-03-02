//
//  Follow.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/31/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct Follow {
    let follower: String
    let following: String
    
    func toAnyObject() -> Any {
        return [
            "follower": follower,
            "following": following
        ]
    }
    
}
