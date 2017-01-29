//
//  ProfilePage.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 15/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//
import Firebase
import UIKit

class ProfilePage: UIViewController {
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userTitle: UINavigationItem!
    @IBOutlet weak var countLbl: UILabel!
    
    var users = [User]()
    
    let storageRef = FIRStorage.storage().reference().child("MyImage.png")
    let databaseRef = FIRDatabase.database().reference().child("users")
    let dataref = FIRDatabase.database().reference()
    
    var friendsDicForCount = [NSDictionary?]()
    
    var timer: Timer?
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.borderColor = UIColor.blue.cgColor
        navigationController?.navigationBar.backgroundColor = UIColor.init(red: 21/255, green: 79/255, blue: 144/255, alpha: 1.0)
        
        
        //user is not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                
                // for some reason uid nil
                return
            }
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if var dictionary = snapshot.value as? [String: AnyObject] {
                    self.userTitle.title = dictionary["name"] as? String
                   
                    let email = snapshot.childSnapshot(forPath: "email").value as! String
                    let name = snapshot.childSnapshot(forPath: "name").value as! String
                    let profileImage = snapshot.childSnapshot(forPath: "profileImageUrl").value as? String
                    let id = snapshot.key
                    let user = User(userEmail: email, userID: id, name: name, profileImageUrl: profileImage)
                    dictionary.removeAll()
                    user.setValuesForKeys(dictionary)
                    if let profileImageUrl = user.profileImageUrl {
                        self.profileImage.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl)
                        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
                        self.profileImage.clipsToBounds = true
                        self.profileImage.contentMode = .scaleAspectFill
                        self.profileImage.translatesAutoresizingMaskIntoConstraints = false
                    }
                    
                }
                
            }, withCancel: nil)
        }
        retrieveFriends()

        // profileImage Edit
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
           self.lbltext()

        })
        
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    func lbltext() {
        if friendsDicForCount.count == 0 {
            countLbl.text = "0"
        } else {
            countLbl.text = "\(friendsDicForCount.count)"
            
        }
    }
    
    @IBAction func LogoutBtn(_ sender: AnyObject) {
        handleLogout()
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    func handleLogout() {
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure to logout?", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "Logout", style: .default, handler:  { (UIAlertAction) in
        
            do {
                try FIRAuth.auth()?.signOut()
            } catch let logoutError {
                print(logoutError)
            }
            
            let loginController = (self.storyboard?.instantiateViewController(withIdentifier:"loginControllerID"))! as! LoginController
            self.present(loginController, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    
    }
    
    func retrieveFriends() {
        let id = FIRAuth.auth()?.currentUser?.uid
        dataref.child("users").child(id!).child("friends").observe(.value, with: { (snapshot) in
            
            if var dictionary = snapshot.value as? [String: Any] {
                for (key, _) in dictionary {
                    self.dataref.child("users").child("\(key)").observe(.value, with: { (snapshot) in
                        let snap = snapshot.value as? NSDictionary
                        
                        let name = snap?["name"] as! String
                        let email = snap?["email"] as! String
                        let profileImageUrl = snap?["profileImageUrl"] as? String
                        
                        _ = ["id": "\(key)", "name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        
                        //self.friendsDic.append(idDic as NSDictionary)
                        self.friendsDicForCount.append(dictionary as NSDictionary?)
                        
                        dictionary.removeAll()
                    })
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}




