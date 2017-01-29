//
//  User.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 16/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    //Request sonradan eklendi firebase**
    
    init(userEmail: String, userID: String, name: String, profileImageUrl: String?) {
        self.email = userEmail
        self.id = userID
        self.profileImageUrl = profileImageUrl
        self.name = name
    }
}
