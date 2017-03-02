//
//  User.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/13/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let username: String
    let userId: String
    let email: String
    let profileImageDownloadUrl: String
    let coverImageDownloadUrl: String
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "username": username,
            "userId": userId,
            "email": email,
            "profileImageDownloadUrl": profileImageDownloadUrl,
            "coverImageDownloadUrl": coverImageDownloadUrl
        ]
    }
}
