//
//  SearchUserViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/30/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let resultsTableView = UITableView()
    let searchBar = UISearchBar()
    
    //Change to followes datasource
    var datasource = UserDatasource()
    
    //Firebase
    let usersRef = FIRDatabase.database().reference(withPath: "users")
    var selectedUserId: String?
    
    var followingUserIds = [String]()
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var searchActive: Bool = false
    var data = [String]()
    var filtered:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change to followes datasource
        datasource = UserDatasource()
        
        setupViews()
        loadFollowingIds()
        
        resultsTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "searchResultsCell")
        resultsTableView.frame = CGRect(x: 0, y: 50, width: 300, height: 300)
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        searchBar.delegate = self
        

        // Do any additional setup after loading the view.
    }
    
    func loadFollowingIds(){
        let followersRef = FIRDatabase.database().reference(withPath: "followers").queryOrdered(byChild: "follower").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid)
        
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.followingUserIds.removeAll()
            for followingUser in snapshot.children {
                let user = followingUser as! FIRDataSnapshot
                let followingId = user.childSnapshot(forPath: "following").value as? String
                self.followingUserIds.append(followingId!)
            }
            self.loadUserData()
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        followersRef.observe(.value, with: { snapshot in
            self.followingUserIds.removeAll()
            for followingUser in snapshot.children {
                let user = followingUser as! FIRDataSnapshot
                let followingId = user.childSnapshot(forPath: "following").value as? String
                self.followingUserIds.append(followingId!)
            }
            self.loadUserData()
        })
        */
    }
    
    func loadUserData(){
        //var followingCounter = 0
        self.datasource.users.removeAll()
        for id in followingUserIds {
            let usersRef = FIRDatabase.database().reference(withPath: "users").queryOrdered(byChild: "userId").queryEqual(toValue: id)
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshot.children {
                    let user = snap as! FIRDataSnapshot
                    self.datasource.convertToUsers(userSnapshot: user)
                }
                self.updateTable()
            }) { (error) in
                print(error.localizedDescription)
            }
            /*
            usersRef.observe(.value, with: { snapshot in
                for snap in snapshot.children {
                    let user = snap as! FIRDataSnapshot
                    self.datasource.convertToUsers(userSnapshot: user)
                }
                self.updateTable()
            })
            */
        }
    }
    
    
    func updateTable(){
        print(datasource.users.count)
        if datasource.users.count >= followingUserIds.count {
            for user in datasource.users {
                data.append(user.name)
            }
            self.resultsTableView.reloadData()
        }
    }
    
    func setupViews(){
        self.view.addSubview(searchBar)
        self.view.addSubview(resultsTableView)
        
        
        searchBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: navBar.frame.height, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        resultsTableView.anchor(searchBar.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsCell", for: indexPath) as! UserTableViewCell
        cell.followButton.isHidden = true
        cell.awakeFromNib()
        let user = datasource.item(indexPath) as! User?
        
        if(searchActive){
            cell.nameLabel.text = filtered[indexPath.row]
            for user in datasource.users {
                if user.name == filtered[indexPath.row] {
                    cell.usernameLabel.text = "@" + user.username
                    cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: user.profileImageDownloadUrl, type: "")
                }
            }
        } else {
            cell.usernameLabel.text = "@" + (user?.username)!
            cell.nameLabel.text = user?.name
            cell.profileImageView.loadImgUsingCacheWithUrlString(urlString: (user?.profileImageDownloadUrl)!, type: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive {
            let selectedUserName = filtered[indexPath.row]
            for user in datasource.users {
                if selectedUserName == user.name {
                    selectedUserId = user.userId
                }
            }
        } else {
            let selectedUser = datasource.item(indexPath) as! User
            print(selectedUser)
            selectedUserId = selectedUser.userId
        }
        self.performSegue(withIdentifier: "toMessageVC", sender: self)
    }
    
    //Search Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    private func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.resultsTableView.reloadData()
    }

    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessageVC" {
            let messageVC = segue.destination as! MessageViewController
            messageVC.otherUserId = selectedUserId
        }
    }
    

}
