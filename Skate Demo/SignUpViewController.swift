//
//  SignUpViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 03/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import ProgressHUD
import ShadowImageView

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    var selectedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Editing the text fields UI
        
//        usernameTextField.backgroundColor = UIColor.clear
//        usernameTextField.tintColor = UIColor.white
//        usernameTextField.textColor = UIColor.white
//        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
//        let bottomLineUsername = CALayer()
//        bottomLineUsername.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
//        bottomLineUsername.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
//        usernameTextField.layer.addSublayer(bottomLineUsername)
//        
//        emailTextField.backgroundColor = UIColor.clear
//        emailTextField.tintColor = UIColor.white
//        emailTextField.textColor = UIColor.white
//        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
//        let bottomLineEmail = CALayer()
//        bottomLineEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
//        bottomLineEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
//        emailTextField.layer.addSublayer(bottomLineEmail)
//        
//        passwordTextField.backgroundColor = UIColor.clear
//        passwordTextField.tintColor = UIColor.white
//        passwordTextField.textColor = UIColor.white
//        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
//        let bottomLinePassword = CALayer()
//        bottomLinePassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
//        bottomLinePassword.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
//        passwordTextField.layer.addSublayer(bottomLinePassword)
        
        //Profile image UI - Half of rectangle in size inspector
        
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
        
        //Tap gesture for user profile image
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImage))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        
        //Button only works when all fields have inputs
        
        signUpButton.isEnabled = false
        
        //Validating  user authentication
        
        handleTextField()
        
    }
    
    //Dismiss keyboard when user touches screen space
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handleTextField() {
        
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty
            else {
                
                signUpButton.isEnabled = false
                return
        }
        
        //When all three fields are filled in the sign up button white color is enabled
        
        signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signUpButton.isEnabled = true
        
    }
    
 
    //User profile image picker
    
    func handleSelectProfileImage() {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissOnClick(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //Signing up the users and sending information to database
    
    @IBAction func signUpButton_TouchUpInside(_ sender: Any) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            
            AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData, onSuccess: {
                
                ProgressHUD.showSuccess("Success")
                
                self.performSegue(withIdentifier: "signUpToTabbarVC", sender: nil)
                
            }, onError: { (errorString) in
                
                ProgressHUD.showError(errorString!)
                
            })
            
        } else {
            
            ProgressHUD.showError("Please select a profile image")
            
            
        }
        
        
    }
    
}



//Extension for showing user image in view

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       
        
        
        print("did finish pick")
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImage.image = image
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
