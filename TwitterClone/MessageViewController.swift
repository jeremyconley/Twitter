//
//  MessageViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/30/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class MessageViewController: JSQMessagesViewController {
    var otherUsername = String()
    
    var otherUserId: String?
    var otherUser: User?
    var currentUser: User?
    
    let messagesRef = FIRDatabase.database().reference(withPath: "messages")
    
    let currUser = FIRAuth.auth()?.currentUser
    var possibleUsers = [FIRDataSnapshot]()
    var possibleMessages = [FIRDataSnapshot]()
    
    // MARK: Properties
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var navBar = UINavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = currUser?.uid
        self.senderDisplayName = currUser?.displayName
       
        self.collectionView.contentInset = UIEdgeInsets(top: 65, left: 0, bottom: 0, right: 0)
        
        setupNavBar()
        
        //Get current user and other user
        //Get other user info
        let userRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: otherUserId!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children{
                let user = item as! FIRDataSnapshot
                
                let username = user.childSnapshot(forPath: "username").value as? String
                let name = user.childSnapshot(forPath: "name").value as? String
                let profPicUrl = user.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
                
                self.otherUser = User(name: name!, username: username!, userId: self.otherUserId!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
                
                let navItem = UINavigationItem(title: "@" + username!);
                let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.handleDoneButton));
                doneItem.tintColor = .white
                navItem.leftBarButtonItem = doneItem
                self.navBar.setItems([navItem], animated: false);
            }
            self.getCurrentUser()
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        userRef.observe(.value, with: { snapshot in
            for item in snapshot.children{
                let user = item as! FIRDataSnapshot
                
                let username = user.childSnapshot(forPath: "username").value as? String
                let name = user.childSnapshot(forPath: "name").value as? String
                let profPicUrl = user.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
                
                self.otherUser = User(name: name!, username: username!, userId: self.otherUserId!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
                
                let navItem = UINavigationItem(title: "@" + username!);
                let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.handleDoneButton));
                doneItem.tintColor = .white
                navItem.leftBarButtonItem = doneItem
                self.navBar.setItems([navItem], animated: false);
            }
            self.getCurrentUser()
        })
        */
    }
    
    func getCurrentUser() {
        let userRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: currUser?.uid)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children{
                let user = item as! FIRDataSnapshot
                
                let username = user.childSnapshot(forPath: "username").value as? String
                let name = user.childSnapshot(forPath: "name").value as? String
                let profPicUrl = user.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
                self.currentUser = User(name: name!, username: username!, userId: self.otherUserId!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
                
            }
            self.observeMessages()
            self.setupBubbles()
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        userRef.observe(.value, with: { snapshot in
            for item in snapshot.children{
                let user = item as! FIRDataSnapshot
                
                let username = user.childSnapshot(forPath: "username").value as? String
                let name = user.childSnapshot(forPath: "name").value as? String
                let profPicUrl = user.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
                self.currentUser = User(name: name!, username: username!, userId: self.otherUserId!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
                
            }
            self.observeMessages()
            self.setupBubbles()
        })
        */
    }
    
    func setupNavBar(){
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        navBar.barTintColor = twitterBlue
        self.view.addSubview(navBar)
        
        navBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: 50)
    }
    
    func handleDoneButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.black)
        //with: UIColor.jsq_colorByDarkeningColor(UIColor.black))
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func observeMessages() {
        let otherUserId = otherUser?.userId
        let currUserId = currUser?.uid
        // 1
        let messagesQuery = messagesRef.queryLimited(toLast: 25)
        // 2
        messagesQuery.observe(.value, with: { snapshot in
            self.possibleMessages.removeAll()
            self.messages.removeAll()
            
            for item in snapshot.children{
                self.possibleMessages.append(item as! FIRDataSnapshot)
            }
            
            for message in self.possibleMessages {
                let senderId = message.childSnapshot(forPath: "senderId")
                let receiverId = message.childSnapshot(forPath: "receiverId")
                let messageContents = message.childSnapshot(forPath: "text")
                
                if (senderId.value as? String)! == currUserId! && (otherUserId)! == (receiverId.value as? String)!{
                    self.addMessage(id: (senderId.value as? String)!, text: (messageContents.value as? String)!)
                } else if (senderId.value as? String)! == (otherUserId)! && (receiverId.value as? String)! == (currUserId)!{
                    self.addMessage(id: (senderId.value as? String)!, text: (messageContents.value as? String)!)
                }
                
            }
            // 5
            
            //self.collectionView.reloadData()
            self.finishReceivingMessage()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        var avatarImg = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: #imageLiteral(resourceName: "profile"))
        let message = messages[indexPath.row]
        if message.senderId == currUser?.uid {
            //Sent from current user
            let userImgUrl = currentUser?.profileImageDownloadUrl
            if userImgUrl != "" {
                let userImgView = UIImageView()
                userImgView.loadImgUsingCacheWithUrlString(urlString: userImgUrl!, type: "")
                avatarImg = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: userImgView.image)
            }
        } else {
            //Sent from other user
            let userImgUrl = otherUser?.profileImageDownloadUrl
            if userImgUrl != "" {
                let userImgView = UIImageView()
                userImgView.loadImgUsingCacheWithUrlString(urlString: userImgUrl!, type: "")
                avatarImg = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: userImgView.image)
            }
        }
        return avatarImg
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //let itemRef = conversationsRef.childByAutoId() // 1
        let receiverId = otherUserId!
        let messageItem:Dictionary<String, Any> = [ // 2
            "text": text,
            "senderId": senderId,
            "receiverId": receiverId
        ]
        messagesRef.childByAutoId().setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        //addMessage(id: senderId, text: text)
        
        // 5
        finishSendingMessage()
    }
}
