//
//  FriendsList.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 09/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FriendsList: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var friendListTableView: UITableView!
    @IBOutlet weak var friendsNavigationItem: UINavigationItem!
    
    var users = [User]()
    var databaseRef = FIRDatabase.database().reference()
    let id = FIRAuth.auth()?.currentUser?.uid

    var friendsDic = [NSDictionary?]()

    var friendsDicForCount = [NSDictionary?]()
    
    static var friendCounts: Int?
    
    let uyari = "****************************************************"
    var timer: Timer?

    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsNavigationItem.title = "Friends"
        friendListTableView.register(UINib(nibName: "FriendsCell", bundle: nil), forCellReuseIdentifier: "FriendsCellXIB")

        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            print(self.uyari)
            print(self.uyari)

        })
        
        FriendSystem.system.addFriendObserver {
            self.friendListTableView.reloadData()
        }
        
    }
    

    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    // Tableview methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FriendSystem.system.friendList.count

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCellXIB", for: indexPath) as! FriendsCell

        cell.labelTxt?.text = FriendSystem.system.friendList[indexPath.row].name
        cell.labelTxt?.textColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0)
        cell.labelTxt?.adjustsFontSizeToFitWidth = true
        cell.labelTxt?.font = UIFont.systemFont(ofSize: 14.0)
        
        if FriendSystem.system.friendList[indexPath.row].profileImageUrl != nil {
            cell.imgView?.loadImagesUsingCacheWithUrlString(urlString: FriendSystem.system.friendList[indexPath.row].profileImageUrl!)
            
        } else {
            cell.imgView?.image = UIImage(named: "emptyPhoto1.png")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let named = FriendSystem.system.friendList[indexPath.row].name
        let urlImg = FriendSystem.system.friendList[indexPath.row].profileImageUrl
        let id = FriendSystem.system.friendList[indexPath.row].id
        let email = FriendSystem.system.friendList[indexPath.row].email
        
        let dic:[String : String?] = ["name": named, "email": email, "id": id, "profileImageUrl": urlImg]
        
        UserProfileVC.dic = dic
        performSegue(withIdentifier: "profilID", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let friendID = FriendSystem.system.friendList[indexPath.row].id!
            FriendSystem.system.removeFriend(friendID)
        }
        
    }
    
}



