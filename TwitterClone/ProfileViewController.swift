//
//  ProfileViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

let twitterBlue = UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    let imagePicker = UIImagePickerController()
    
    enum ImageType {
        case Profile
        case Cover
    }
    var picType: ImageType?
    
    enum TableType {
        case Tweets
        case Media
        case Likes
    }
    var currTableType: TableType = .Tweets
    
    let tweetsTableView = UITableView()
    
    //Firebase
    let ref = FIRDatabase.database().reference()
    var currUser: User?
    var datasource = TweetDatasource()
    var thisUserFollowersCount = 0
    var thisUserFollowingCount = 0
    
    var likedTweets = [String]()
    var likedTweetSnaps = [FIRDataSnapshot]()
    
    //Layout
    let coverImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return imgView
    }()
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        imgView.layer.borderColor = UIColor.white.cgColor
        imgView.layer.borderWidth = 3
        return imgView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        return label
    }()
    
    let followingNumber: UILabel = {
        let label = UILabel()
        label.text = "55"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let followingLabel: UILabel = {
        let label = UILabel()
        label.text = "FOLLOWING"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        return label
    }()
    
    let followersNumber: UILabel = {
        let label = UILabel()
        label.text = "123"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let followersLabel: UILabel = {
        let label = UILabel()
        label.text = "FOLLOWERS"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        return label
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1), for: .normal)
        return button
    }()
    
    let tweetsButton: UIButton = {
        let button = UIButton()
        //button.layer.cornerRadius = 5
        button.layer.borderColor = twitterBlue.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Tweets", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = twitterBlue
        return button
    }()
    let mediaButton: UIButton = {
        let button = UIButton()
        //button.layer.cornerRadius = 5
        button.layer.borderColor = twitterBlue.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Media", for: .normal)
        button.setTitleColor(twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //button.backgroundColor = twitterBlue
        return button
    }()
    let likesButton: UIButton = {
        let button = UIButton()
        let twitterBlue = UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)
        //button.layer.cornerRadius = 5
        button.layer.borderColor = twitterBlue.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Likes", for: .normal)
        button.setTitleColor(twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //button.backgroundColor = twitterBlue
        return button
    }()
    
    func switchToTweets(){
        currTableType = .Tweets
        tweetsTableView.reloadData()
        tweetsButton.backgroundColor = twitterBlue
        tweetsButton.setTitleColor(.white, for: .normal)
        mediaButton.backgroundColor = .white
        mediaButton.setTitleColor(twitterBlue, for: .normal)
        likesButton.backgroundColor = .white
        likesButton.setTitleColor(twitterBlue, for: .normal)
    }
    func switchToMedia(){
        currTableType = .Media
        tweetsTableView.reloadData()
        mediaButton.backgroundColor = twitterBlue
        mediaButton.setTitleColor(.white, for: .normal)
        tweetsButton.backgroundColor = .white
        tweetsButton.setTitleColor(twitterBlue, for: .normal)
        likesButton.backgroundColor = .white
        likesButton.setTitleColor(twitterBlue, for: .normal)
    }
    func switchToLikes(){
        currTableType = .Likes
        likesButton.backgroundColor = twitterBlue
        likesButton.setTitleColor(.white, for: .normal)
        mediaButton.backgroundColor = .white
        mediaButton.setTitleColor(twitterBlue, for: .normal)
        tweetsButton.backgroundColor = .white
        tweetsButton.setTitleColor(twitterBlue, for: .normal)
        
        
        //Load likes
        let likesRef = FIRDatabase.database().reference(withPath: "likes").queryOrdered(byChild: "userId").queryEqual(toValue: currUser?.userId)
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.likedTweets.removeAll()
            for tweet in snapshot.children {
                let thisTweet = tweet as! FIRDataSnapshot
                let tweetId = thisTweet.childSnapshot(forPath: "tweetId").value as? String
                self.likedTweets.append(tweetId!)
            }
            self.loadLikedTweets()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadLikedTweets(){
        self.likedTweetSnaps.removeAll()
        for tweetId in likedTweets {
            let ref = FIRDatabase.database().reference(withPath: "tweets").queryOrdered(byChild: "tweetId").queryEqual(toValue: tweetId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                for tweet in snapshot.children {
                    let thisTweet = tweet as! FIRDataSnapshot
                    self.likedTweetSnaps.append(thisTweet)
                }
                self.updateLikesTable()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func updateLikesTable(){
        print(likedTweetSnaps.count)
        if likedTweetSnaps.count >= likedTweets.count {
            tweetsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUser()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        self.view.addSubview(tweetsTableView)
        tweetsTableView.register(TweetTableViewCell.self, forCellReuseIdentifier: "userTweetCell")
        tweetsTableView.register(MediaTableViewCell.self, forCellReuseIdentifier: "userMediaCell")
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        
        tweetsTableView.frame = CGRect(x: 0, y: 50, width: 300, height: 300)

        // Do any additional setup after loading the view.
    }
    
    func loadUser(){
        let userRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid)
        
        
        userRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            for item in snapshot.children{
                let username = snapshot.childSnapshot(forPath: "username").value as? String
                let id = snapshot.childSnapshot(forPath: "userId").value as? String
                let name = snapshot.childSnapshot(forPath: "name").value as? String
                let profPicUrl = snapshot.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
                let coverImgUrl = snapshot.childSnapshot(forPath: "coverImageDownloadUrl").value as? String
                
                self.currUser = User(name: name!, username: username!, userId: id!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
                
                self.usernameLabel.text = "@" + username!
                self.nameLabel.text = name
                self.profileImageView.loadImgUsingCacheWithUrlString(urlString: profPicUrl!, type: "profileControllerPic")
                if profPicUrl != "" {
                    self.profileImageView.loadImgUsingCacheWithUrlString(urlString: profPicUrl!, type: "profileControllerPic")
                } else {
                    self.profileImageView.image = #imageLiteral(resourceName: "profile")
                }
                if coverImgUrl != "" {
                    self.coverImageView.loadImgUsingCacheWithUrlString(urlString: coverImgUrl!, type: "")
                } else {
                    self.coverImageView.image = nil
                    self.coverImageView.backgroundColor = .gray
                }
                
                
            }
            self.loadCurrUserTweets()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        /*
        userRef.observe(.childAdded, with: { snapshot in
            let username = snapshot.childSnapshot(forPath: "username").value as? String
            let id = snapshot.childSnapshot(forPath: "userId").value as? String
            let name = snapshot.childSnapshot(forPath: "name").value as? String
            let profPicUrl = snapshot.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
            let coverImgUrl = snapshot.childSnapshot(forPath: "coverImageDownloadUrl").value as? String
            
            self.currUser = User(name: name!, username: username!, userId: id!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
            
            self.usernameLabel.text = "@" + username!
            self.nameLabel.text = name
            self.profileImageView.loadImgUsingCacheWithUrlString(urlString: profPicUrl!, type: "profileControllerPic")
            if coverImgUrl != "" {
                self.coverImageView.loadImgUsingCacheWithUrlString(urlString: coverImgUrl!, type: "")
            }
            self.loadCurrUserTweets()
        })
        */
        
    }

    func loadCurrUserTweets(){
        let tweetsRef = FIRDatabase.database().reference(withPath: "tweets").queryOrdered(byChild: "userId").queryEqual(toValue: currUser?.userId)
        self.datasource.tweets.removeAll()
        
        tweetsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for tweet in snapshot.children {
                self.datasource.convertToTweets(tweetSnapshot: tweet as! FIRDataSnapshot)
            }
            self.datasource.tweets.reverse()
            self.tweetsTableView.reloadData()
            self.loadCurrentUserFollowersCount()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        /*
        tweetsRef.observe(.value, with: { snapshot in
            for tweet in snapshot.children {
                self.datasource.convertToTweets(tweetSnapshot: tweet as! FIRDataSnapshot)
            }
            self.datasource.tweets.reverse()
            self.tweetsTableView.reloadData()
            self.loadCurrentUserFollowersCount()
        })
        */
    }
    
    func loadCurrentUserFollowersCount(){
        let followersRef = FIRDatabase.database().reference(withPath: "followers").queryOrdered(byChild: "following").queryEqual(toValue: currUser?.userId)
        
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.thisUserFollowersCount = 0
            for followingUser in snapshot.children {
                self.thisUserFollowersCount += 1
            }
            self.loadCurrentUserFollowingCount()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        /*
        followersRef.observe(.value, with: { snapshot in
            self.thisUserFollowersCount = 0
            for followingUser in snapshot.children {
                self.thisUserFollowersCount += 1
            }
            self.loadCurrentUserFollowingCount()
        })
        */
    }
    func loadCurrentUserFollowingCount(){
        let followersRef = FIRDatabase.database().reference(withPath: "followers").queryOrdered(byChild: "follower").queryEqual(toValue: currUser?.userId)
        
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.thisUserFollowingCount = 0
            for followingUser in snapshot.children {
                self.thisUserFollowingCount += 1
            }
            //Call setup views after getting all info
            self.setupViews()
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        followersRef.observe(.value, with: { snapshot in
            self.thisUserFollowingCount = 0
            for followingUser in snapshot.children {
                self.thisUserFollowingCount += 1
            }
            //Call setup views after getting all info
            self.setupViews()
        })
        */
    }
    
    func setupViews(){
        self.view.addSubview(coverImageView)
        self.view.addSubview(profileImageView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(usernameLabel)
        self.view.addSubview(editProfileButton)
        self.view.addSubview(followingNumber)
        self.view.addSubview(followingLabel)
        self.view.addSubview(followersNumber)
        self.view.addSubview(followersLabel)
        self.view.addSubview(mediaButton)
        self.view.addSubview(tweetsButton)
        self.view.addSubview(likesButton)
        
        likesButton.addTarget(self, action: #selector(switchToLikes), for: .touchUpInside)
        mediaButton.addTarget(self, action: #selector(switchToMedia), for: .touchUpInside)
        tweetsButton.addTarget(self, action: #selector(switchToTweets), for: .touchUpInside)
        
        followingNumber.text = "\(thisUserFollowingCount)"
        followersNumber.text = "\(thisUserFollowersCount)"
        
        
        
        coverImageView.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.view.frame.width, heightConstant: self.view.frame.width/5)
        self.navigationItem.titleView = coverImageView
        
        profileImageView.anchor(coverImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, topConstant: -15, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 85, heightConstant: 85)
        
        nameLabel.anchor(profileImageView.bottomAnchor, left: profileImageView.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        usernameLabel.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
        editProfileButton.anchor(coverImageView.bottomAnchor, left: nil, bottom: nil, right: self.view.rightAnchor, topConstant: 35, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 100, heightConstant: 25)
        editProfileButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        
        followingNumber.anchor(usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        followingLabel.anchor(followingNumber.topAnchor, left: followingNumber.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        followersNumber.anchor(followingNumber.topAnchor, left: followingLabel.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        followersLabel.anchor(followersNumber.topAnchor, left: followersNumber.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        let buttonWidth = (self.view.frame.width / 3) - 15
        let buttonHeight = buttonWidth / 4
        tweetsButton.anchor(followingNumber.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonHeight)
        mediaButton.anchor(tweetsButton.topAnchor, left: tweetsButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonHeight)
        likesButton.anchor(tweetsButton.topAnchor, left: mediaButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonHeight)
        tweetsTableView.anchor(likesButton.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        //tweetsTableView.anchor(likesButton.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func handleEditProfile(){
        showEditSetting()
    }
    
    let blackView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        let collecView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecView.backgroundColor = .black
        return collecView
    }()
    let editOptions = ["Change Profile Picture", "Change Cover Picture", "Cancel"]
    func showEditSetting(){
        if let window = UIApplication.shared.keyWindow {
            
            //Overlay View
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissOverlay)))
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let height: CGFloat = 200
            let y = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(EditProfileCollectionViewCell.self, forCellWithReuseIdentifier: "editProfileCell")
            //Initial Animation
            blackView.frame = window.frame
            blackView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
                }, completion: { (completed) in
                    //
            })
        }
    }
    
    func handleDismissOverlay(){
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.blackView.alpha = 0
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 200)
                }, completion: { (completed) in
                    //
            })
        }
    }
    
    //Settings Collection View
    //Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editProfileCell", for: indexPath) as! EditProfileCollectionViewCell
        cell.title.text = editOptions[indexPath.row]
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Change prof
            picType = .Profile
            handleDismissOverlay()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            //Change cover
            picType = .Cover
            handleDismissOverlay()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
        } else {
            handleDismissOverlay()
        }
    }
    
    //ImgPicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImage(image: image, name: (currUser?.userId)!, type: picType!)
        } else{
            print("Something went wrong")
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    func uploadImage(image: UIImage, name: String, type: ImageType){
        var refPath: String?
        if type == .Profile {
            refPath = "profilePictures"
            if let path = refPath {
                let storage = FIRStorage.storage().reference(withPath: path)
                let imgRef = storage.child(name)
                if let uploadData = UIImageJPEGRepresentation(image, 0.1){
                    imgRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error)
                        } else {
                            print("woo")
                            let downloadurl = metadata?.downloadURL()?.absoluteString
                            
                            self.updateUserPicture(updatedUrl: downloadurl!)
                        }
                    })
                }
            }
        } else {
            refPath = "coverPictures"
            if let path = refPath {
                let storage = FIRStorage.storage().reference(withPath: path)
                let imgRef = storage.child(name)
                if let uploadData = UIImageJPEGRepresentation(image, 0.1){
                    imgRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error)
                        } else {
                            print("woo")
                            let downloadurl = metadata?.downloadURL()?.absoluteString
                            
                            self.updateUserCoverPicture(updatedUrl: downloadurl!)
                        }
                    })
                }
            }
        }
    }
    
    func updateUserPicture(updatedUrl: String) {
        let usersRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: self.currUser?.userId)
        
        usersRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.ref.child("users").child(snapshot.key).updateChildValues(["profileImageDownloadUrl": updatedUrl])
            
            self.updateExistingTweetsPic(updatedUrl: updatedUrl)
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        usersRef.observe(.childAdded, with: { snapshot in
            self.ref.child("users").child(snapshot.key).updateChildValues(["profileImageDownloadUrl": updatedUrl])
            
            self.updateExistingTweetsPic(updatedUrl: updatedUrl)
        })
        */
    }
    
    func updateExistingTweetsPic(updatedUrl: String) {
        let tweetsRef = FIRDatabase.database().reference(withPath: "tweets").queryOrdered(byChild: "userId").queryEqual(toValue: self.currUser?.userId)
        
        
        tweetsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for tweet in snapshot.children {
                let userTweet = tweet as! FIRDataSnapshot
                let key = userTweet.key
                
                self.ref.child("tweets").child(key).updateChildValues(["userProfilePicDownloadUrl": updatedUrl])
            }
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        tweetsRef.observe(.value, with: { snapshot in
            for tweet in snapshot.children {
                let userTweet = tweet as! FIRDataSnapshot
                let key = userTweet.key
                
                self.ref.child("tweets").child(key).updateChildValues(["userProfilePicDownloadUrl": updatedUrl])
            }
            self.dismiss(animated: true, completion: nil)
        })
        */
    }
    
    func updateUserCoverPicture(updatedUrl: String){
        let usersRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: self.currUser?.userId)
        
        usersRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.ref.child("users").child(snapshot.key).updateChildValues(["coverImageDownloadUrl": updatedUrl])
            
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        usersRef.observe(.childAdded, with: { snapshot in
            self.ref.child("users").child(snapshot.key).updateChildValues(["coverImageDownloadUrl": updatedUrl])
            
            self.dismiss(animated: true, completion: nil)
        })
        */
    }
    
    //Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        switch currTableType {
        case .Tweets:
            return datasource.tweets.count
        case .Likes:
            return likedTweets.count
        case .Media:
            return 2
        default:
            break
        }
        print(numOfRows)
        
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentCell = UITableViewCell()
        switch currTableType {
        case .Tweets:
            var cell = tableView.dequeueReusableCell(withIdentifier: "userTweetCell", for: indexPath) as! TweetTableViewCell
            cell.awakeFromNib()
            let tweet = datasource.item(indexPath) as! Tweet?
            
            cell.nameLabel.text = tweet?.name
            cell.usernameLabel.text = "@" + (tweet?.username)!
            cell.tweetTextView.text = tweet?.tweet
            cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: (tweet?.userProfilePicDownloadUrl)!, type: "")
            
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
            
            //Get likes for tweet
            let tweetId = tweet?.tweetId
            let ref = FIRDatabase.database().reference(withPath: "likes").queryOrdered(byChild: "tweetId").queryEqual(toValue: tweetId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                cell.tweetlikerIDs.removeAll()
                for like in snapshot.children {
                    let thisLike = like as! FIRDataSnapshot
                    let likerId = thisLike.childSnapshot(forPath: "userId").value as? String
                    cell.tweetlikerIDs.append(likerId!)
                }
                cell.numberOfLikesLabel.text = "\(cell.tweetlikerIDs.count)"
            }) { (error) in
                print(error.localizedDescription)
            }
      
            
            currentCell = cell
            
        case .Likes:
            var cell = tableView.dequeueReusableCell(withIdentifier: "userTweetCell", for: indexPath) as! TweetTableViewCell
            cell.awakeFromNib()
            
            let tweet = likedTweetSnaps[indexPath.row]
            
            let name = tweet.childSnapshot(forPath: "name").value as? String
            let username = tweet.childSnapshot(forPath: "username").value as? String
            let userId = tweet.childSnapshot(forPath: "userId").value as? String
            let profilePicUrl = tweet.childSnapshot(forPath: "userProfilePicDownloadUrl").value as? String
            let tweetText = tweet.childSnapshot(forPath: "tweet").value as? String
            let date =  tweet.childSnapshot(forPath: "tweetDate").value as? String
            let tweetId = tweet.childSnapshot(forPath: "tweetId").value as? String
            
            
            cell.nameLabel.text = name
            cell.usernameLabel.text = "@" + username!
            cell.tweetTextView.text = tweetText!
            cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: profilePicUrl!, type: "")
            
            let tweetDate = date!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let dateObj = dateFormatter.date(from: date!)
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
            
            
            //Get likes for tweet
            let thisTweetId = tweetId
            let ref = FIRDatabase.database().reference(withPath: "likes").queryOrdered(byChild: "tweetId").queryEqual(toValue: thisTweetId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                cell.tweetlikerIDs.removeAll()
                for like in snapshot.children {
                    let thisLike = like as! FIRDataSnapshot
                    let likerId = thisLike.childSnapshot(forPath: "userId").value as? String
                    cell.tweetlikerIDs.append(likerId!)
                }
                cell.numberOfLikesLabel.text = "\(cell.tweetlikerIDs.count)"
            }) { (error) in
                print(error.localizedDescription)
            }

            currentCell = cell
            
            
        case .Media:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userMediaCell", for: indexPath) as! MediaTableViewCell
            cell.awakeFromNib()
            
            if indexPath.row == 0 {
                cell.mediaImageView.image = profileImageView.image
            } else {
                cell.mediaImageView.image = coverImageView.image
            }
            
            currentCell = cell
            
        default:
            break
        }
        
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow: CGFloat = 0
        switch currTableType {
        case .Tweets:
            let tweet = datasource.item(indexPath) as! Tweet?
            let approximateWidth = view.frame.width - 12 - 50 - 12 - 2
            let size = CGSize(width: approximateWidth, height: 1000)
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            //Get estimation of cell height based on user.bioText
            let estimatedFrame = NSString(string: (tweet?.tweet)!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            heightForRow = CGFloat(estimatedFrame.height + 100)
        case .Likes:
            let tweet = likedTweetSnaps[indexPath.row]
            let tweetText = tweet.childSnapshot(forPath: "tweet").value as? String
            let approximateWidth = view.frame.width - 12 - 50 - 12 - 2
            let size = CGSize(width: approximateWidth, height: 1000)
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            //Get estimation of cell height based on user.bioText
            let estimatedFrame = NSString(string: tweetText!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            heightForRow = CGFloat(estimatedFrame.height + 100)
        case .Media:
            if indexPath.row == 0 {
                //Prof pic
                heightForRow = 200
            } else {
                heightForRow = 75
            }
            
        default:
            break
        }
        return heightForRow
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
