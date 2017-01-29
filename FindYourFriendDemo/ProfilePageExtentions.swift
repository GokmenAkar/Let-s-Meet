//
//  ProfilePageExtentions.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 18/10/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase

extension ProfilePage: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
    // Profile Image
    func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismiss(animated: true, completion: nil)

        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = editedImage
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = orginalImage
        } else {
            profileImage.image = nil
        }
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let profileImageView = self.profileImage.image, let uploadData = UIImageJPEGRepresentation(profileImageView, 0.1){
        
            
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }

                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    let values = ["profileImageUrl": profileImageUrl]
                    
                    self.userIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    
                    
                }
                
                
            })
            
        }
        

    }
    
    private func userIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://findyourfrienddemo.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
                }
            
        })
    }
    
    func profileImageHandler(uid: String, values: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://findyourfrienddemo.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        
        
        userReference.updateChildValues(values, withCompletionBlock: {
            (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
            
            
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }

}

