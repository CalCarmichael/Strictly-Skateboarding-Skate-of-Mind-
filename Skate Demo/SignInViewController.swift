//
//  SignInViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 03/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import ProgressHUD
import TKSubmitTransitionSwift3
import TextFieldEffects

class SignInViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var SignUp: UIButton!
    
    @IBOutlet weak var signInButton: TKTransitionSubmitButton!
    
    var btn: TKTransitionSubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
         btn = TKTransitionSubmitButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 64, height: 44))
        
        
       
        
        
        //Editing the text fields UI
        
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
        
        //Button only works when text fields input
        
        signInButton.isEnabled = false
        
        
        handleTextField()
        
    }
    
    //Dismiss the keyboard when user touches other screen space
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //Log user back in if they had previously signed in on same device without logging out
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Withiin UserApi
        
        if Api.User.CURRENT_USER != nil {
            
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
            
        } else {
            
        }
        
        
        
    }
    
    //When the text field changes and all are filled in the sign in button becomes white
    
    func handleTextField() {
        
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty
            else {
                
                signInButton.isEnabled = false
                return
        }
        
        //When all three fields are filled in the sign up button white color is enabled
        
        signInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signInButton.isEnabled = true
        
    }
    
    func textFieldShouldReturn(_ emailTextField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    //Authorizing sign in button (within AuthService)
    
    @IBAction func signInButton(_ button: TKTransitionSubmitButton) {
        
        
        
        view.endEditing(true)
        
           button.animate(1, completion: { () -> () in
            
             self.leaveAnimation()
            
            AuthService.signIn(email: self.emailTextField.text!, password: self.passwordTextField.text!, onSuccess: {
                
             
                //Sending to main tabbar page when successful sign in
              self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
                
                
            }, onError: { error in
                
                ProgressHUD.showError(error!)
                
                
            })
            
        })
        
    }
    
    func leaveAnimation() {
        
        emailTextField.alpha = 1
        passwordTextField.alpha = 1
        SignUp.alpha = 1
    
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.emailTextField.alpha = 0
            self.passwordTextField.alpha = 0
            self.SignUp.alpha = 0
            
            
        }) { (finished) in
            
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
            
        }
        
    }
    
    
    
    
//    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
//        
//        view.endEditing(true)
//       
//        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
//            ProgressHUD.showSuccess("Success")
//            
//            //Sending to main tabbar page when successful sign in
//            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
//            
//        }, onError: { error in
//            ProgressHUD.showError(error!)
//           
//            
//        })
//        
//    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return TKFadeInAnimator(transitionDuration: 0.3, startingAlpha: 0.8)
        
    }
        
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
        
}

}
