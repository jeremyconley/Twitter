//
//  FindPeopleViewController.swift
//  TwitterClone
//
//  Created by Jeremy Conley on 1/31/17.
//  Copyright © 2017 JeremyConley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class FindPeopleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let usersTableView = UITableView()
    let searchBar = UISearchBar()
    var datasource = UserDatasource()
    
    var searchActive: Bool = false
    var data = [String]()
    var filtered:[String] = []
    
    var selectedUserId: String?
    
    //Firebase
    let usersRef = FIRDatabase.database().reference(withPath: "users")
    //Location following users
    var followingUserIds = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Find People"
        
        setupViews()
        usersTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "findUsersCell")
        usersTableView.frame = CGRect(x: 0, y: 50, width: 300, height: 300)
        usersTableView.delegate = self
        usersTableView.dataSource = self

        searchBar.delegate = self

        // Do any additional setup after loading the view.
    }
    
   
    func loadData(){
        self.filtered.removeAll()
        self.data.removeAll()
        self.datasource.users.removeAll()
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children{
                //self.userSnapshots.append(item as! FIRDataSnapshot)
                let user = item as! FIRDataSnapshot
                let userId = user.childSnapshot(forPath: "userId").value as? String
                if userId != FIRAuth.auth()?.currentUser?.uid {
                    self.datasource.convertToUsers(userSnapshot: user)
                }
            }
            self.updateTable()
        }) { (error) in
            print(error.localizedDescription)
        }
        /*
        usersRef.observe(.value, with: { snapshot in
            for item in snapshot.children{
                //self.userSnapshots.append(item as! FIRDataSnapshot)
                let user = item as! FIRDataSnapshot
                let userId = user.childSnapshot(forPath: "userId").value as? String
                if userId != FIRAuth.auth()?.currentUser?.uid {
                    self.datasource.convertToUsers(userSnapshot: user)
                }
            }
            self.updateTable()
        })
        */
    }
    
    func updateTable(){
        for user in datasource.users {
            data.append(user.name)
        }
        print(datasource.users.count)
        
        self.usersTableView.reloadData()
    }
 
    
    func setupViews(){
        self.view.addSubview(searchBar)
        self.view.addSubview(usersTableView)
        
        
        searchBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usersTableView.anchor(searchBar.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 55, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(searchActive) {
            return filtered.count
        }
        return data.count
    }
    
    var followers = [String]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "findUsersCell", for: indexPath) as! UserTableViewCell
        cell.awakeFromNib()
        let user = datasource.item(indexPath) as! User?
        
        //Check if current user is following this user
        for id in followingUserIds {
            if id == user?.userId {
                //cell.followButton.setImage(#imageLiteral(resourceName: "following"), for: .normal)
                //followers.append((user?.username)!)
            }
        }
        
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
        var selectedUser: User?
        if searchActive {
            let selectedUserName = filtered[indexPath.row]
            for user in datasource.users {
                if selectedUserName == user.name {
                    selectedUserId = user.userId
                }
            }
        } else {
            selectedUser = datasource.item(indexPath) as! User
            selectedUserId = selectedUser?.userId
        }
        performSegue(withIdentifier: "toOtherUser", sender: self)
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
        self.usersTableView.reloadData()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOtherUser" {
            let otherUserVC = segue.destination as! OtherUserProfileViewController
            if let id = selectedUserId {
                otherUserVC.thisUserId = id
            }
        }
    }
    

}
