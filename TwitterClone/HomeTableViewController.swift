//
//  HomeTableViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class HomeTableViewController: UITableViewController {
    
    var datasource = TweetDatasource()
    
    let tweetRef = FIRDatabase.database().reference(withPath: "tweets")
    let likesRef = FIRDatabase.database().reference(withPath: "likes")
    let notificationsRef = FIRDatabase.database().reference(withPath: "notifications")
    let tweetSnaps = [FIRDataSnapshot]()
    
    var followingUserIds = [String]()
    var currUserId = String()
    
    var followingCounter = 0
    
    //Var for selected user segue
    var selectedUserId: String?
    
    //Alerts
    var alert = UIAlertController()
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let user = FIRAuth.auth()?.currentUser {
            //LoggedIn
            currUserId = (FIRAuth.auth()?.currentUser?.uid)!
            loadFollowingIds()
        } else {
            performSegue(withIdentifier: "toLogin", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        datasource = TweetDatasource()
        
    }
    
    func loadFollowingIds(){
        followingUserIds.removeAll()
        let followersRef = FIRDatabase.database().reference(withPath: "followers").queryOrdered(byChild: "follower").queryEqual(toValue: currUserId)
        followingUserIds.append(currUserId)
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for followingUser in snapshot.children {
                let user = followingUser as! FIRDataSnapshot
                let followingId = user.childSnapshot(forPath: "following").value as? String
                self.followingUserIds.append(followingId!)
            }
            self.loadFollowingTweets()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        /*
        followersRef.observe(.value, with: { snapshot in
            for followingUser in snapshot.children {
                let user = followingUser as! FIRDataSnapshot
                let followingId = user.childSnapshot(forPath: "following").value as? String
                self.followingUserIds.append(followingId!)
            }
            self.loadFollowingTweets()
        })
        */
    }
    
    func loadFollowingTweets(){
        self.datasource.tweets.removeAll()
        followingCounter = 0
        for id in followingUserIds {
            followingCounter += 1
            let followingTweetsRef = FIRDatabase.database().reference(withPath: "tweets").queryOrdered(byChild: "userId").queryEqual(toValue: id)
            
            followingTweetsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshot.children {
                    let tweet = snap as! FIRDataSnapshot
                    self.datasource.convertToTweets(tweetSnapshot: tweet)
                }
                //Check if on the last following user
                if self.followingCounter == self.followingUserIds.count {
                    self.updateTable()
                }
            })
            
            { (error) in
                print(error.localizedDescription)
            }
            /*
            followingTweetsRef.observe(.value, with: { snapshot in
                for snap in snapshot.children {
                    let tweet = snap as! FIRDataSnapshot
                    self.datasource.convertToTweets(tweetSnapshot: tweet)
                }
                //Check if on the last following user
                if self.followingCounter == self.followingUserIds.count {
                    self.updateTable()
                }
            })
            */
        }
    }
    
    
    func updateTable(){
        self.datasource.tweets.sort(by: { $0.tweetDate > $1.tweetDate })
        self.tableView.reloadData()
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
        return datasource.tweets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        
        //Tweet Cell Info
        let tweet = datasource.item(indexPath) as! Tweet?
        cell.tweetUserId = (tweet?.userId)!
        cell.tweetId = (tweet?.tweetId)!
        
        cell.usernameLabel.text = "@" + (tweet?.username)!
        cell.nameLabel.text = tweet?.name
        cell.tweetTextView.text = tweet?.tweet
        cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: (tweet?.userProfilePicDownloadUrl)!, type: "")
        cell.profileImageButton.addTarget(self, action: #selector(handleUserPicTouched(_:)), for: .touchUpInside)
        
        cell.likeButton.addTarget(self, action: #selector(handleLikeButton(_:)), for: .touchUpInside)
        
        //Get likes for tweet
        let tweetId = cell.tweetId
        let ref = FIRDatabase.database().reference(withPath: "likes").queryOrdered(byChild: "tweetId").queryEqual(toValue: tweetId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var userHasLiked = false
            cell.tweetlikerIDs.removeAll()
            for like in snapshot.children {
                let thisLike = like as! FIRDataSnapshot
                let likerId = thisLike.childSnapshot(forPath: "userId").value as? String
                cell.tweetlikerIDs.append(likerId!)
            }
            for likeId in cell.tweetlikerIDs {
                if likeId == self.currUserId {
                    //User has already liked tweet
                    userHasLiked = true
                }
            }
            if userHasLiked == true {
                cell.likeButton.tintColor = .red
            } else {
                cell.likeButton.tintColor = .gray
            }
            cell.numberOfLikesLabel.text = "\(cell.tweetlikerIDs.count)"
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let tweetDate = tweet?.tweetDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateObj = dateFormatter.date(from: tweetDate!)
        let currentDate = NSDate()
        
        //Tweet Cell Time Label
        var distanceBetweenDates = currentDate.timeIntervalSince(dateObj!)
        let hoursBetweenDates = (distanceBetweenDates/3600)
        let minutesBetweenDates = (distanceBetweenDates/60)
        let secondsBetweenDates = distanceBetweenDates
        
        if hoursBetweenDates >= 24 {
            //Has Been Days
            let numOfDays = Int(hoursBetweenDates / 24)
            cell.timeSinceTweetLabel.text = "\(numOfDays)d"
            
        } else if hoursBetweenDates >= 1 {
            //Has been Hours
            cell.timeSinceTweetLabel.text = "\(Int(hoursBetweenDates))h"
        } else {
            //Has been minutes of seconds
            if minutesBetweenDates >= 1 {
                //Minutes
                cell.timeSinceTweetLabel.text = "\(Int(minutesBetweenDates))m"
            } else {
                //Seconds
                cell.timeSinceTweetLabel.text = "\(Int(secondsBetweenDates))s"
            }
        }
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let tweet = datasource.item(indexPath) as? Tweet {
            let approximateWidth = view.frame.width - 12 - 50 - 12 - 2
            let size = CGSize(width: approximateWidth, height: 1000)
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            //Get estimation of cell height based on user.bioText
            let estimatedFrame = NSString(string: tweet.tweet).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            return CGFloat(estimatedFrame.height + 100)
        }
        
        return 200
        
    }
    
    func handleUserPicTouched(_ sender: UIButton) {
        var tweetCell = sender.superview
        if tweetCell is TweetTableViewCell {
            let cell = tweetCell as! TweetTableViewCell
            selectedUserId = cell.tweetUserId
            performSegue(withIdentifier: "toOtherUser", sender: self)
        }
    }
    
    
    func handleLikeButton(_ sender: UIButton){
        var tweetCell = sender.superview
        if tweetCell is TweetTableViewCell {
            let cell = tweetCell as! TweetTableViewCell
            let tweetId = cell.tweetId
            var userHasLikedTweet = false
            
            //Check if user has liked tweet
            for id in cell.tweetlikerIDs {
                if id == currUserId {
                    //User has already liked tweet
                    userHasLikedTweet = true
                }
            }
            
            if !userHasLikedTweet {
                cell.tweetlikerIDs.append(currUserId)
                cell.likeButton.tintColor = .red
                var numOfLikesInt = Int(cell.numberOfLikesLabel.text!)
                numOfLikesInt! += 1
                cell.numberOfLikesLabel.text = "\(numOfLikesInt!)"
                
                let newLike = LikeTweet(userId: self.currUserId, tweetId: tweetId)
                self.likesRef.childByAutoId().setValue(newLike.toAnyObject())
                //Check if tweet owner is not the current user to send notification
                if currUserId != cell.tweetUserId {
                    //Send tweet owner a notification
                    let currentDate = NSDate()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                    let dateString = dateFormatter.string(from:currentDate as Date)
                    
                    let newNotification = Notification(notification: "Liked your tweet!", fromUser: currUserId, toUser: cell.tweetUserId, date: dateString)
                    notificationsRef.childByAutoId().setValue(newNotification.toAnyObject())
                }
                
            } else {
                //User has already liked tweet
            }
        }
    }
    
    func setupNavigationBarItems(){
        setupLeftNavItem()
        setupRightNavItems()
        setUpRemainingNavItems()
    }
    
    private func setUpRemainingNavItems(){
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "title_icon"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    private func setupLeftNavItem(){
        let followButton = UIButton(type: .system)
        followButton.setImage(#imageLiteral(resourceName: "follow").withRenderingMode(.alwaysOriginal), for: .normal)
        followButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        followButton.addTarget(self, action: #selector(findPeopleSegue), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: followButton)
    }
    
    private func setupRightNavItems(){
        //Logout Button
        let logOutButton = UIButton(type: .system)
        logOutButton.setImage(#imageLiteral(resourceName: "logout").withRenderingMode(.alwaysOriginal), for: .normal)
        logOutButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        logOutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        //Compose Button
        let composeButton = UIButton(type: .system)
        composeButton.setImage(#imageLiteral(resourceName: "compose").withRenderingMode(.alwaysOriginal), for: .normal)
        composeButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        composeButton.addTarget(self, action: #selector(composeSegue), for: .touchUpInside)
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: composeButton)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: composeButton), UIBarButtonItem(customView: logOutButton)]
    }
    
    func findPeopleSegue(){
        self.performSegue(withIdentifier: "findPeople", sender: self)
    }
    
    func composeSegue(){
        self.performSegue(withIdentifier: "composeSegue", sender: self)
    }
    func handleLogout(){
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOtherUser" {
            let otherUserVC = segue.destination as! OtherUserProfileViewController
            if let id = selectedUserId {
                otherUserVC.thisUserId = id
            }
        }
    }
}

//Compare dates
extension NSDate: Comparable {
    static public func <(a: NSDate, b: NSDate) -> Bool {
        return a.compare(b as Date) == ComparisonResult.orderedAscending
    }
    
    static public func ==(a: NSDate, b: NSDate) -> Bool {
        return a.compare(b as Date) == ComparisonResult.orderedSame
    }
    
}

