//
//  LoginViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 29/03/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if FIRAuth.auth()?.currentUser?.uid != nil {
            
            self.performSegue(withIdentifier: "Login", sender: nil)
            
        }
        
    }
    
    func login() {
        
        FIRAuth.auth()?.signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
            
            if error != nil {
                
                print(error!)
                return
                
            }
            
             self.performSegue(withIdentifier: "Login", sender: nil)
            
            
        })
        
    }
    
    
    @IBAction func loginButtonAction(_ sender: Any) {
    
        login()
        
    }
    
}
