//
//  NotificationDatasource.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation

class NotificationDatasource: Datasource {
    let notifications: [Notification] = {
    
        let notification1 = Notification(notification: "liked your tweet", fromUser: "John Wall", toUser: "Jeremy")
        let notification2 = Notification(notification: "followed you", fromUser: "Greg Jones", toUser: "Jeremy")
        let notification3 = Notification(notification: "liked your tweet", fromUser: "Frank James", toUser: "Jeremy")
        let notification4 = Notification(notification: "followed you", fromUser: "Dan Williams", toUser: "Jeremy")

        return [notification1, notification2, notification3, notification4]
    }()
    
    
    override func numberOfItems(_ section: Int) -> Int {
        return notifications.count
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return notifications[indexPath.item]
    }
}
