//
//  MessageController.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 16/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var messagesTableView: UITableView!
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        checkIfUserIsLoggedIn()
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        
        let image = UIImage(named: "new_message_icon")
        navigationBar.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(hadnleNewMessage))
        
        navigationBar.rightBarButtonItem?.tintColor = UIColor.darkGray
        
        messagesTableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        messagesTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
             return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let profileImage = snapshot.childSnapshot(forPath: "profileImageUrl").value as? String
            let id = snapshot.key
            let user = User(userEmail: email, userID: id, name: name, profileImageUrl: profileImage)
            user.id = chatPartnerId
            print(dictionary)
       //     user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }

    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    // Funcs
    var messages = [Message]()
    var messagesDictionary = [String: Message]()

    func observeUserMessages() {
        if uid != nil {
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid!)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            ref.child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
        }
    }

    private func fetchMessageWithMessageId(messageId: String) {
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    private func attemptReloadOfTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }

    func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
        }
    }
    
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        let navChatController = UINavigationController(rootViewController: chatLogController)
        present(navChatController, animated: true, completion: nil)
    }
    
    func hadnleNewMessage() {
    
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func checkIfUserIsLoggedIn() {
        //user is not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            /*let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationBar.title = dictionary["name"] as? String
                }
                
                }, withCancel: nil)*/
            fetchUserAndSetupNavBarTitle()
        }
    }
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let email = snapshot.childSnapshot(forPath: "email").value as! String
                let name = snapshot.childSnapshot(forPath: "name").value as! String
                let profileImage = snapshot.childSnapshot(forPath: "profileImageUrl").value as? String
                let id = snapshot.key
                let user = User(userEmail: email, userID: id, name: name, profileImageUrl: profileImage)
                dictionary.removeAll()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        messagesTableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl)
        } else {
            profileImageView.image = UIImage(named: "emptyPhoto1.png")
            profileImageView.tintColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationBar.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = (self.storyboard?.instantiateViewController(withIdentifier:"loginControllerID"))! as! LoginController
        self.present(loginController, animated: true, completion: nil)
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //

    
}

