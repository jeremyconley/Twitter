//
//  Notification.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

struct Notification {
    let notification: String
    let fromUser: String
    let toUser: String
    let date: String
    
    func toAnyObject() -> Any {
        return [
            "notification": notification,
            "fromUser": fromUser,
            "toUser": toUser,
            "date": date
        ]
    }
}
