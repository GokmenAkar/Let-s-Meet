//
//  UserProfileVC.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 09/12/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userImg: UIImageView!
    //@IBOutlet weak var followBtn: UIButton!
    
    static var dic = [String : String?]()
    
    var loggedInUser = FIRAuth.auth()?.currentUser//store the auth details of the logged in user
    var loggedInUserData:NSDictionary? //the users data from the database will be stored in this variable
    var databaseRef:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = UserProfileVC.dic["name"]!
        navigationController?.navigationBar.backgroundColor = UIColor.init(red: 21/255, green: 79/255, blue: 144/255, alpha: 1.0)

        self.userImg.clipsToBounds = true
        self.userImg.layer.cornerRadius = self.userImg.frame.size.width / 2
        self.userImg.layer.borderWidth = 3
        self.userImg.layer.borderColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0).cgColor
        
        if UserProfileVC.dic["profileImageUrl"]! == nil {
            print("Kullanici resmi yok")
            userImg.image = UIImage(named: "emptyPhoto1.png")
        } else {
            print("Kullanici resmi var")
            userImg.loadImagesUsingCacheWithUrlString(urlString: UserProfileVC.dic["profileImageUrl"]!!)
        }
        
   
    }
    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func followButton(_ sender: UIButton) {
        
        
    }

}






















