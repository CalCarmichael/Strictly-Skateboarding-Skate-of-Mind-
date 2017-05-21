//
//  EditProfileViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 30/03/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var displayNameText: UITextField!
    @IBOutlet weak var bioText: UITextField!
    
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
       
        loadProfileData()
        
    }
    
    //Saving the edit profile changes
    
    @IBAction func saveProfileData(_ sender: Any) {
    
        updateUserProfile()

    }
    
    @IBAction func cancelUpdate(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
    func updateUserProfile(){
        
        //Checking user is logged in
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
        
        //Access point to firebase storage
        
        let storageItem = storageRef.child("Profile_Images").child(userID)
        
        //Upload image from photo library else keep it
            
        guard let image = profileImageView.image else {return}
            
        if let newImage = UIImagePNGRepresentation(image) {
        
        //Upload to firebase
            
        storageItem.put(newImage, metadata: nil, completion: { (metadata, error) in
            if error != nil {
            
            print(error!)
            
            return
            
            }
            
            storageItem.downloadURL(completion: { (url, error) in
                if error != nil {
                print(error!)
                return
                
                }
                
                if let profilePhotoURL = url?.absoluteString {
                    
                    guard let newUsername = self.usernameText.text else {return}
                    guard let newDisplayName = self.displayNameText.text else {return}
                    guard let newBioText = self.bioText.text else {return}
                    
                    let newValuesForProfile =
                    
                        ["photo": profilePhotoURL,
                         "username": newUsername,
                         "display": newDisplayName,
                         "bio" : newBioText]
                    
                  //Update user information to firebase database 
                    
                    self.databaseRef.child("Profile").child(userID).updateChildValues(newValuesForProfile, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                            
                        }
                        
                        print("Profile Successfully Updated")
                        
                    })
                    
                }
                    
            })
            
        })

    }
  }
}
    
    
    //User can change photo
    
    @IBAction func getPhotoFromLibrary(_ sender: Any) {
    
    let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.allowsEditing = false
        
        picker.sourceType = .photoLibrary
        
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        present(picker, animated: true, completion: nil)
        
    }
    
    //Updating image chosen
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var chosenImage = UIImage()
        
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profileImageView.image = chosenImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //User cancel image
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func loadProfileData() {
        
        //When user logs in the profile data from Firebase retrieved
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            databaseRef.child("Profile").child(userID).observe(.value, with: { (snapshot) in
                
                //Dictionary of user profile data created
                
                let values = snapshot.value as? NSDictionary
                
                //URL image stored in photo
                
                if let profileImageURL = values?["photo"] as? String {
                    
                //sd_setImages loads the photo
                
                self.profileImageView.sd_setImage(with: URL(string: profileImageURL))
        
        }
            
                self.usernameText.text = values?["username"] as? String
                self.displayNameText.text = values?["display"] as? String
                self.bioText.text = values?["bio"] as? String
                
            
        })
        
      }
    

    }

}
