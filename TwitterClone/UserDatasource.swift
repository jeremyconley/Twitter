//
//  UserDatasource.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class UserDatasource: Datasource {
    
    //let usersRef = FIRDatabase.database().reference(withPath: "users")
    //var userSnapshots = [FIRDataSnapshot]()
    
    var users = [User]()
    
    /*
    let users: [User] = {
        let user1 = User(name: "Danny Gibs", username: "@dannyg", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user2 = User(name: "John Johnson", username: "@johnny", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user3 = User(name: "Greg Daniels", username: "@sissy", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user4 = User(name: "Joe Smoe", username: "@lilboy", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user5 = User(name: "Bob Fron", username: "@bobbyo", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user6 = User(name: "Frank Jones", username: "@frankthetank", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user7 = User(name: "Jeff Williams", username: "@jeffyboy", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        let user8 = User(name: "Chris Wilson", username: "@wilson", userId: "", email: "", profileImageDownloadUrl: "", coverImageDownloadUrl: "")
        return [user1, user2, user3, user4, user5, user6, user7, user8]
    }()
    */
    
    /*
    func loadData(){
        usersRef.observe(.value, with: { snapshot in
            for item in snapshot.children{
                self.userSnapshots.append(item as! FIRDataSnapshot)
            }
            self.convertToUsers()
        })
    }
    */
    
    func convertToUsers(userSnapshot: FIRDataSnapshot) {
        
        let user = userSnapshot
        let name = user.childSnapshot(forPath: "name").value as? String
        let username = user.childSnapshot(forPath: "username").value as? String
        let email = user.childSnapshot(forPath: "email").value as? String
        let userId = user.childSnapshot(forPath: "userId").value as? String
        let profilePicUrl = user.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
        let coverImgUrl = user.childSnapshot(forPath: "coverImageDownloadUrl").value as? String
            
        let currentUser = User(name: name!, username: username!, userId: userId!, email: email!, profileImageDownloadUrl: profilePicUrl!, coverImageDownloadUrl: coverImgUrl!)
        users.append(currentUser)
        
    }
    
    
    override func numberOfItems(_ section: Int) -> Int {
        return users.count
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return users[indexPath.item]
    }
    
}
