//
//  MessagesTableViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/30/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessagesTableViewController: UITableViewController {
    
    var selectedUserId: String?
    var willPresentMessageVC = false
    
    var userIdsCurrentlyMessaging = [String]()
    var usersCurrentlyMessaging = [FIRDataSnapshot]()

    override func viewDidAppear(_ animated: Bool) {
        loadMessagingUsers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
    }
    
    func loadMessagingUsers() {
        let messagesRef = FIRDatabase.database().reference(withPath: "messages")
        
        userIdsCurrentlyMessaging.removeAll()
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let message = snap as! FIRDataSnapshot
                let receiverId = message.childSnapshot(forPath: "receiverId").value as? String
                let senderId = message.childSnapshot(forPath: "senderId").value as? String
                if senderId == FIRAuth.auth()?.currentUser?.uid {
                    if self.userIdsCurrentlyMessaging.contains(receiverId!){
                        //user has already been added
                    } else {
                        self.userIdsCurrentlyMessaging.append(receiverId!)
                    }
                } else if receiverId == FIRAuth.auth()?.currentUser?.uid {
                    if self.userIdsCurrentlyMessaging.contains(senderId!){
                        //user has already been added
                    } else {
                        self.userIdsCurrentlyMessaging.append(senderId!)
                    }
                }
            }
            self.loadUsersFromIds()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadUsersFromIds(){
        usersCurrentlyMessaging.removeAll()
        for id in userIdsCurrentlyMessaging {
            let usersRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: id)
    
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for followingUser in snapshot.children {
                    let user = followingUser as! FIRDataSnapshot
                    self.usersCurrentlyMessaging.append(user)
                }
                self.updateTable()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateTable(){
        if usersCurrentlyMessaging.count >= userIdsCurrentlyMessaging.count {
            self.tableView.reloadData()
        }
    }
    
    func setupNavBar(){
        self.navigationItem.title = "Messages"
        self.navigationItem.rightBarButtonItem?.tintColor = twitterBlue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userIdsCurrentlyMessaging.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessageVC" {
            let messageVC = segue.destination as! MessageViewController
            messageVC.otherUserId = selectedUserId
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageUserCell", for: indexPath) as! UserTableViewCell
        cell.awakeFromNib()
        let user = usersCurrentlyMessaging[indexPath.row]
        let username = user.childSnapshot(forPath: "username").value as? String
        let name = user.childSnapshot(forPath: "name").value as? String
        let profPicUrl = user.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
        
        cell.nameLabel.text = name
        cell.usernameLabel.text = "@" + username!
        if profPicUrl != "" {
            cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: profPicUrl!, type: "")
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = usersCurrentlyMessaging[indexPath.row]
        let userId = user.childSnapshot(forPath: "userId").value as? String
        selectedUserId = userId
        self.performSegue(withIdentifier: "toMessageVC", sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
