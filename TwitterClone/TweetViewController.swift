//
//  TweetViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/31/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TweetViewController: UIViewController, UITextViewDelegate {
    
    var invalidTweet = false
    var currUser: User?
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        return label
    }()
    
    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "84"
        label.font = UIFont.systemFont(ofSize: 16)
        //label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        return label
    }()
 
    let tweetTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = "What's happening?"
        textView.isSelectable = true
        return textView
    }()
    
    let tweetButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderColor = twitterBlue.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Send Tweet", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(twitterBlue, for: .normal)
        return button
    }()
    
    let navigationBar = UINavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUser()
        setupViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    func handleDismissKeyboard(){
        tweetTextView.resignFirstResponder()
    }
    
    func loadUser(){
        let userRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid)
        
        userRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            let username = snapshot.childSnapshot(forPath: "username").value as? String
            let id = snapshot.childSnapshot(forPath: "userId").value as? String
            let name = snapshot.childSnapshot(forPath: "name").value as? String
            let profPicUrl = snapshot.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
            
            self.currUser = User(name: name!, username: username!, userId: id!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
            
            self.usernameLabel.text = "@" + username!
            self.profileImageView.loadImgUsingCacheWithUrlString(urlString: profPicUrl!, type: "")
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        userRef.observe(.childAdded, with: { snapshot in
            let username = snapshot.childSnapshot(forPath: "username").value as? String
            let id = snapshot.childSnapshot(forPath: "userId").value as? String
            let name = snapshot.childSnapshot(forPath: "name").value as? String
            let profPicUrl = snapshot.childSnapshot(forPath: "profileImageDownloadUrl").value as? String
            
            self.currUser = User(name: name!, username: username!, userId: id!, email: "", profileImageDownloadUrl: profPicUrl!, coverImageDownloadUrl: "")
            
            self.usernameLabel.text = "@" + username!
            self.profileImageView.loadImgUsingCacheWithUrlString(urlString: profPicUrl!, type: "")
        })
        */
    }
    
    func setupViews(){
        self.view.addSubview(tweetTextView)
        self.view.addSubview(navigationBar)
        self.view.addSubview(usernameLabel)
        self.view.addSubview(profileImageView)
        self.view.addSubview(characterCountLabel)
        self.view.addSubview(tweetButton)
        
        tweetTextView.delegate = self
        
        tweetButton.addTarget(self, action: #selector(sendTweet), for: .touchUpInside)
        
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/5)
        navigationBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        self.navigationItem.title = "Send Tweet"
        navigationBar.pushItem(self.navigationItem, animated: true)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTweet))
        self.navigationItem.rightBarButtonItem = cancelButton
        
        profileImageView.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, topConstant: 55, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        usernameLabel.anchor(self.profileImageView.topAnchor, left: self.profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        tweetTextView.anchor(profileImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 15, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: self.view.frame.width - 20, heightConstant: self.view.frame.height/3)
        
        characterCountLabel.anchor(nil, left: nil, bottom: tweetTextView.topAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        tweetButton.anchor(self.tweetTextView.bottomAnchor, left: nil, bottom: nil, right: self.view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 125, heightConstant: 35)
        
    }
    
    func sendTweet(){
        if invalidTweet == false {
            //Good to go
            let currentDate = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let dateString = dateFormatter.string(from:currentDate as Date)
            
            let tweetId = UUID().uuidString
            
            let tweet = Tweet(userId: (currUser?.userId)!, username: (currUser?.username)!, name: (currUser?.name)!, tweet: tweetTextView.text, userProfilePicDownloadUrl: (currUser?.profileImageDownloadUrl)!, tweetDate: dateString, tweetId: tweetId)
            let tweetsRef = FIRDatabase.database().reference(withPath: "tweets")
            tweetsRef.childByAutoId().setValue(tweet.toAnyObject())
            dismiss(animated: true, completion: nil)
        } else {
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingCharacters()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    
    func checkRemainingCharacters(){
        let allowedCharacters = 100
        let charsInTextView = -tweetTextView.text.characters.count
        let remainingCharacters = allowedCharacters + charsInTextView
        if remainingCharacters <= allowedCharacters {
            invalidTweet = false
            characterCountLabel.textColor = UIColor.black
        }
        if remainingCharacters <= 20 {
            invalidTweet = false
            characterCountLabel.textColor = UIColor.orange
        }
        if remainingCharacters <= 10 {
            invalidTweet = false
            characterCountLabel.textColor = UIColor.red
        }
        if remainingCharacters <= 0 {
            invalidTweet = true
        }
        
        characterCountLabel.text = "\(remainingCharacters)"
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func cancelTweet(){
        dismiss(animated: true, completion: nil)
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
