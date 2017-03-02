//
//  MediaTableViewCell.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/15/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {
    
    let mediaImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubview(mediaImageView)
        mediaImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 10, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
