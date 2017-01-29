//
//  NewMessageController.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 16/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase


class NewMessageController: UITableViewController {

    var users = [User]()
    var databaseRef = FIRDatabase.database().reference()
    
    var friendsDic = [NSDictionary?]()
    var friendsDicForCount = [NSDictionary?]()
    
    static var friendCounts: Int?
    
    let uyari = "****************************************************"
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        retrieveFriends()

        tableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "cellXIB")
        tableView.delegate = self
        tableView.dataSource = self
        
        FriendSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }


    }
    // -- TableView Methods -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsDicForCount.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celll = tableView.dequeueReusableCell(withIdentifier: "cellXIB", for: indexPath) as! Cell
        
        celll.buttonImg.isHidden = true
        
        let friendUser = users[(indexPath as NSIndexPath).row]
        
        celll.labelTxt.text = friendUser.name
        
        if friendUser.profileImageUrl != nil {
            celll.imgView.loadImagesUsingCacheWithUrlString(urlString: friendUser.profileImageUrl!)
        } else {
            celll.imgView.image = UIImage(named: "emptyPhoto1.png")
        }
        
        return celll
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let user = self.users[indexPath.row]
            self.showChatControllerForUser(user: user)
        
    }
    
    // -- // Funcs // -- // -- // -- // -- //
    
    func retrieveFriends() {
        let id = FIRAuth.auth()?.currentUser?.uid
        databaseRef.child("users").child(id!).child("friends").observe(.value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: Any] {
                for (key, _) in dictionary {
                    self.databaseRef.child("users").child("\(key)").observe(.value, with: { (snapshot) in
                        let snap = snapshot.value as? NSDictionary
                        
                        let name = snap?["name"] as! String
                        let email = snap?["email"] as! String
                        let profileImageUrl = snap?["profileImageUrl"] as? String
                        
                        let user = User(userEmail: email, userID: "\(key)", name: name, profileImageUrl: profileImageUrl)
                        
                        self.users.append(user)
                        self.friendsDicForCount.append(dictionary as NSDictionary?)
                        
                        dictionary.removeAll()
                    })
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}


