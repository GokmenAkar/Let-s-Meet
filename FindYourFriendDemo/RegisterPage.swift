//
//  RegisterPage.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 12/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RegisterPage: UIViewController {
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var registerBtnImage: UIButton!
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerBtnImage.layer.cornerRadius = 5
        usernameTextField.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passTextField.layer.cornerRadius = 5
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // -- // -- // -- // -- // -- // -- // -- // -- // -- //-- // -- // -- // -- // -- // -- // -- // -- // -- //
    
    // Buttons 
    @IBAction func toLoginBtn(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func registerBtn(_ sender: AnyObject) {
        
        let tabBarConroller = (self.storyboard?.instantiateViewController(withIdentifier:"navigationID"))! as! NavigationController
        self.present(tabBarConroller, animated: true, completion: nil)
        
        guard let email = emailTextField.text, let password = passTextField.text, let name = usernameTextField.text else {

            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user: FIRUser?, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user 
            let ref = FIRDatabase.database().reference(fromURL: "https://findyourfrienddemo.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
                
                print("Saved user successfully into Firebase db")
            })

        })
    }
}
