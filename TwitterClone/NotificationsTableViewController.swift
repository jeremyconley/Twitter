//
//  NotificationsTableViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NotificationsTableViewController: UITableViewController {
    
    var notifications = [Notification]()
    
    override func viewDidAppear(_ animated: Bool) {
        loadNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = falsvar        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadNotifications(){
        let notificationsRef = FIRDatabase.database().reference(withPath: "notifications").queryOrdered(byChild: "toUser").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid)
        notifications.removeAll()
        notificationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let notification = snap as! FIRDataSnapshot
                let notificationText = notification.childSnapshot(forPath: "notification").value as? String
                let notificationSender = notification.childSnapshot(forPath: "fromUser").value as? String
                let notificationReceiver = notification.childSnapshot(forPath: "toUser").value as? String
                let notificationDate = notification.childSnapshot(forPath: "date").value as? String
                let newNotification = Notification(notification: notificationText!, fromUser: notificationSender!, toUser: notificationReceiver!, date: notificationDate!)
                self.notifications.append(newNotification)
            }
            self.notifications.reverse()
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
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
        return notifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        cell.awakeFromNib()
        let notification = notifications[indexPath.row]
        let senderUserId = notification.fromUser
        let receiverUserId = notification.toUser
        let notificationText = notification.notification
        let date = notification.date
        
        //Get notification sender user info
        let userRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: senderUserId)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for user in snapshot.children {
                let thisUser = user as! FIRDataSnapshot
                let userPicUrl = thisUser.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
                let userName = thisUser.childSnapshot(forPath: "name").value as? String
                cell.nameLabel.text = userName
                if userPicUrl != "" {
                    cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: userPicUrl!, type: "")
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "profile")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        cell.notificationLabel.text = notificationText
        var notificationImg = UIImage()
        if notificationText == "Liked your tweet!" {
            let likeImage = UIImage(named: "heartIcon")?.withRenderingMode(.alwaysTemplate)
            notificationImg = likeImage!
            cell.notificationImage.tintColor = .red
        } else {
            let followImage = UIImage(named: "following")?.withRenderingMode(.alwaysTemplate)
            notificationImg = followImage!
            cell.notificationImage.tintColor = twitterBlue
        }
        
        cell.notificationImage.image = notificationImg
        
        let notificationDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateObj = dateFormatter.date(from: notificationDate)
        let currentDate = NSDate()
        
        //Tweet Cell Time Label
        var distanceBetweenDates = currentDate.timeIntervalSince(dateObj!)
        let hoursBetweenDates = (distanceBetweenDates/3600)
        let minutesBetweenDates = (distanceBetweenDates/60)
        let secondsBetweenDates = distanceBetweenDates
        
        if hoursBetweenDates >= 24 {
            //Has Been Days
            let numOfDays = Int(hoursBetweenDates / 24)
            cell.dateLabel.text = "\(numOfDays)d"
            
        } else if hoursBetweenDates >= 1 {
            //Has been Hours
            cell.dateLabel.text = "\(Int(hoursBetweenDates))h"
        } else {
            //Has been minutes of seconds
            if minutesBetweenDates >= 1 {
                //Minutes
                cell.dateLabel.text = "\(Int(minutesBetweenDates))m"
            } else {
                //Seconds
                cell.dateLabel.text = "\(Int(secondsBetweenDates))s"
            }
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
