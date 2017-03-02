//
//  TweetTableViewCell.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    //Use for segue to tweet user vc
    var tweetUserId = String()
    //Use for liking tweets
    var tweetId = String()
    var tweetlikerIDs = [String]()
    
    let profileImageButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        imgView.image = #imageLiteral(resourceName: "profile")
        return imgView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Jeremy Conley"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@jeremyc"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        return label
    }()
    
    let tweetTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.backgroundColor = .clear
        textView.isSelectable = false
        return textView
    }()
    
    let timeSinceTweetLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "1d"
        return label
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        let heartImage = UIImage(named: "heartIcon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(heartImage, for: .normal)
        button.tintColor = .gray
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    let retweetButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "retweetIcon"), for: .normal)
        return button
    }()
    let numberOfLikesLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .gray
        return label
    }()
    let numberOfRetweetsLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .gray
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        
        addSubview(profileImageView)
        addSubview(profileImageButton)
        addSubview(nameLabel)
        addSubview(timeSinceTweetLabel)
        addSubview(usernameLabel)
        addSubview(tweetTextView)
        addSubview(likeButton)
        addSubview(retweetButton)
        addSubview(numberOfLikesLabel)
        addSubview(numberOfRetweetsLabel)

        profileImageButton.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        profileImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        
        nameLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 20)
        
        timeSinceTweetLabel.anchor(nameLabel.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
        
        usernameLabel.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
        tweetTextView.anchor(usernameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: -2, leftConstant: -4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        retweetButton.anchor(tweetTextView.bottomAnchor, left: tweetTextView.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 3, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 20, heightConstant: 15)
        numberOfRetweetsLabel.anchor(likeButton.topAnchor, left: retweetButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        likeButton.anchor(retweetButton.topAnchor, left: numberOfRetweetsLabel.rightAnchor, bottom: nil, right: nil, topConstant: -2, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        numberOfLikesLabel.anchor(likeButton.topAnchor, left: likeButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
