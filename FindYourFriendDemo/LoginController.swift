//
//  ViewController.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 08/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    var window: UIWindow?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    // funcs 
    
    func checkIfUserIsLoggedIn() {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        //user is not logged in
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 1000)
        } else if uid != nil {
            
            self.window?.rootViewController = (self.storyboard?.instantiateViewController(withIdentifier: "navigationID"))! as! NavigationController
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                }, withCancel: nil)
        }
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
    // Buttons
    @IBAction func signUpBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "loginID", sender: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }
    
    @IBAction func loginButton(_ sender: AnyObject) {

        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passTextField.text!, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let tabBarConroller = (self.storyboard?.instantiateViewController(withIdentifier:"navigationID"))! as! NavigationController
                self.present(tabBarConroller, animated: true, completion: nil)
        })
        
    }

}

