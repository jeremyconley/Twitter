//
//  LaunchAnimationViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 2/18/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit

class LaunchAnimationViewController: UIViewController {
    
    let logoImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = #imageLiteral(resourceName: "twitterWhite")
        return imgView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = twitterBlue
        
        view.addSubview(logoImgView)
        logoImgView.frame.size = CGSize(width: 100, height: 100)
        logoImgView.center = view.center
        
        UIView.animate(withDuration: 0.2, delay: 1, options: .curveEaseOut, animations: {
            self.logoImgView.frame.size = CGSize(width: 50, height: 50)
            self.logoImgView.center = self.view.center
            }) { (completed) in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    self.logoImgView.frame.size = CGSize(width: self.view.frame.width * 4, height: (self.view.frame.height * 4) + 300)
                    self.logoImgView.center = self.view.center
                }) { (completed) in
                    self.performSegue(withIdentifier: "toRootVC", sender: self)
                }
        }

        // Do any additional setup after loading the view.
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
