//
//  SearchVC.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 04/12/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    var segmentIndex = 0
    
    var users = [User]()
    let cell = Cell()

    let searchController = UISearchController(searchResultsController: nil)

    // -- //
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: FIRUser?
    var otherUser: NSDictionary?
    var loggedInUserData: NSDictionary?
    // -- //
    
    var usersArray = [NSDictionary?]()
    var filteredUser = [NSDictionary?]()
    var requestUsers = [NSDictionary?]()
    var requestUsersID = [NSDictionary?]()
    var requestCount: Int?
    
    static var badgeCount: String?
    
    var timer: Timer?
    let uyari = "****************************************************"
    // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- // -- //

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchUser()
        segmentIndex = segmentControl.selectedSegmentIndex
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.tabBarItem.badgeValue = SearchVC.badgeCount
        
        tableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "cellXIB")
        refFunctions()
        FriendSystem.system.addRequestObserver {
            print(FriendSystem.system.requestList)
            
            self.requestCount = FriendSystem.system.requestList.count
            let sayi = "\(self.requestCount)"
            
            self.tableView.reloadData()
        }

        
    }

    //TableView Methods // -- // -- // -- //-- // -- //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rInt = -1

        if segmentIndex == 0 {
            searchController.searchBar.isHidden = false
            rInt = self.filteredUser.count
            
            if searchController.isActive && searchController.searchBar.text != "" && segmentIndex == 0 {
                return filteredUser.count
            }
        }
        
        if segmentIndex == 1 {
            rInt = self.requestCount!
        }
        
        return rInt
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellXIB", for: indexPath) as! Cell
        var user: NSDictionary?
        
        if segmentIndex == 0 {
            cell.buttonImg.setTitle("Send a Request", for: UIControlState())

            if searchController.isActive && searchController.searchBar.text != "" {
                user = filteredUser[indexPath.row]
            }
            
            cell.labelTxt?.text = user?["name"] as? String
            
            if user?["profileImageUrl"] == nil {
                cell.imgView.image = UIImage(named: "emptyPhoto1.png")
            } else {
                cell.imgView.loadImagesUsingCacheWithUrlString(urlString: user?["profileImageUrl"] as! String)
                cell.imgView.layer.cornerRadius = cell.imgView.frame.width/2 
            }
            
            cell.setFunction {
                let id = "\(user?["uid"] as! String)"
                FriendSystem.system.sendRequestToUser(id)
            }
            
        }
        if FriendSystem.system.requestList == nil {
            print("Arkadaslik istegi yok")
        } else {

        if segmentIndex == 1 {
            searchController.searchBar.isHidden = true
            cell.buttonImg.setTitle("Accept", for: UIControlState())
            cell.labelTxt.text = FriendSystem.system.requestList[indexPath.row].name
            let img = FriendSystem.system.requestList[indexPath.row].profileImageUrl
            
            if img == nil {
                cell.imgView.image = UIImage(named: "emptyPhoto1.png")
            } else {
                cell.imgView.loadImagesUsingCacheWithUrlString(urlString: img!)
            }

            cell.setFunction {
                let id = FriendSystem.system.requestList[indexPath.row].id
                FriendSystem.system.acceptFriendRequest(id!)
            }
            
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentIndex == 0 {
            let user: NSDictionary?
            user = filteredUser[indexPath.row]
            
            let named = user?["name"] as! String
            let urlImg = user?["profileImageUrl"] as? String
            let id = user?["uid"] as! String
            let email = user?["email"] as! String
            
            let dic:[String : String?] = ["name": named, "email": email, "id": id, "profileImageUrl": urlImg]
            
            
            UserProfileVC.dic = dic
            performSegue(withIdentifier: "profilID", sender: nil)
        }
        
        if segmentIndex == 1 {
            var userReq: NSDictionary?
            userReq = requestUsers[indexPath.row]
            
            let namedd = userReq?["name"] as! String
            let urlImgg = userReq?["profileImageUrl"] as? String
            let idd = userReq?["uid"] as? String
            let emaill = userReq?["email"] as! String
            
            let dicc:[String : String?] = ["name": namedd, "email": emaill, "id": idd, "profileImageUrl": urlImgg]
            
            
            UserProfileVC.dic = dicc
            
            performSegue(withIdentifier: "profilID", sender: nil)

        }
    }
    
    // Update Search // -- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    func updateSearchResults(for searchController: UISearchController) { 
        filteredContent(searchText: self.searchController.searchBar.text!)
    }

    func filteredContent(searchText: String) {
        self.filteredUser = self.usersArray.filter({ (user) -> Bool in
            
            let username = user!["name"] as? String
            return (username?.lowercased().contains((searchText.lowercased())))!
        })
        
        tableView.reloadData()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: AnyObject] {
                let email = snapshot.childSnapshot(forPath: "email").value as! String
                let name = snapshot.childSnapshot(forPath: "name").value as! String
                let profileImage = snapshot.childSnapshot(forPath: "profileImageUrl").value as? String
                let id = snapshot.key
                let user = User(userEmail: email, userID: id, name: name, profileImageUrl: profileImage)
                
                user.id = snapshot.key
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                dictionary.removeAll()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async  {
                    self.tableView.reloadData()
                }
                
            }
            
        }, withCancel: nil)
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    @IBAction func segmentFunc(_ sender: UISegmentedControl) {
        self.segmentIndex = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    func refFunctions() {
        databaseRef.child("users").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            let snap = snapshot.value as? NSDictionary
            snap?.setValue(key, forKey: "uid")
            
            if (key == self.loggedInUser?.uid) {
                print("same as loggedin user")
            } else {
                self.usersArray.append(snap)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        /** Request of users */
        
        let id = FIRAuth.auth()?.currentUser?.uid
        databaseRef.child("users").child(id!).child("requests").observe(.value, with: { (snapshot) in
            
            let snap = snapshot.value as? NSDictionary
            
            if snap != nil {
            for (key, val) in snap! {
                self.databaseRef.child("users").child("\(key)").observe(.value, with: { (snapshot) in
                    let snap = snapshot.value as? NSDictionary
                    let keyVal = ["\(key)": "\(val)"]
                    
                    self.requestUsers.append(snap!)
                    self.requestUsersID.append(keyVal as NSDictionary?)
                })
            }
                
            } else {

            }
        })
        
            { (error) in
            print(error.localizedDescription)
        }
        
    }
    
}


