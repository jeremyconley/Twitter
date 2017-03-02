//
//  EditProfileLauncher.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/9/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class EditProfileLauncher: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
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
            

            /*
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            })
            */
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
        } else if indexPath.row == 1 {
            //Change cover
        } else {
            handleDismissOverlay()
        }
    }

}
