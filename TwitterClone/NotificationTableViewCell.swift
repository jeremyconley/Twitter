//
//  NotificationTableViewCell.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/29/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "liked your tweet"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    let notificationImage: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        return label
    }()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
        
    }
    
    func setupViews(){
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(notificationLabel)
        addSubview(notificationImage)
        addSubview(dateLabel)
        
        profileImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        nameLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        notificationImage.anchor(nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, topConstant: 3, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 25)
        
        notificationLabel.anchor(notificationImage.topAnchor, left: notificationImage.rightAnchor, bottom: nil, right: nil, topConstant: 2, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        dateLabel.anchor(nameLabel.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
