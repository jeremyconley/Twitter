//
//  EditProfileCollectionViewCell.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/9/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class EditProfileCollectionViewCell: UICollectionViewCell {
    let title: UILabel = {
        let label = UILabel()
        let twitterBlue = UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)
        label.textColor = twitterBlue
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(title)
        title.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
        
        //title.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        //title.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        title.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
