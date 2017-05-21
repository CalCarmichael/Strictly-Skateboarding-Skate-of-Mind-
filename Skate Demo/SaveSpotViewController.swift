//
//  SaveSpotViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 12/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import Firebase
import Mapbox
import IBAnimatable

class SaveSpotViewController: UIViewController {
    
    @IBOutlet weak var skateTitleText: UITextField!
    @IBOutlet weak var skateStyleText: UITextField!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var saveSpotPopUpView: UIView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var gradientView: UIImageView!
    
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    
    var options = ["Select Type", "Skatepark", "Street Skating", "Favourite Spots"]
    
    var skateparks = [Skatepark]()
    
    var user: FIRUser!
    
    var effect: UIVisualEffect!
    
    var locationManager = CLLocationManager()
    
    let locationsRef = FIRDatabase.database().reference(withPath: "locations")

    override func viewDidLoad() {
        super.viewDidLoad()

        saveSpotPopUpView.alpha = 0
        
        saveSpotPopUpView.layer.cornerRadius = 10
        saveSpotPopUpView.layer.masksToBounds = true
        
        
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 5
        addButton.clipsToBounds = true
        addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        addButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        
        closeButton.layer.borderWidth = 1
        closeButton.layer.cornerRadius = 5
        closeButton.clipsToBounds = true
        closeButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        closeButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)

        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        animateBackgroundGradient()
        
        animateVisualEffectView()
        
        animateVisualEffect()
        
        
        
        
        
    }
    
  
   
    
    
    func animateVisualEffectView() {
        
        UIView.animate(withDuration: 0.5) { 
            
            self.visualEffect.alpha = 1
            self.visualEffect.transform = CGAffineTransform.identity
            
        }
        
    }
    
    //Animating pop up in and visual effect
    
    func animateVisualEffect() {
        
      
        saveSpotPopUpView.center = self.saveSpotPopUpView.center
        saveSpotPopUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
            
            
            self.saveSpotPopUpView.alpha = 1
            self.saveSpotPopUpView.transform = CGAffineTransform.identity

            
        }, completion: nil)
        
        
    }
    
    
    func animateBackgroundGradient() {
        
        UIView.animate(withDuration: 15, delay: 0, options: [.autoreverse, .curveLinear, .repeat], animations: {
            
            let x = -(self.gradientView.frame.width - self.view.frame.width)
            
            self.gradientView.transform = CGAffineTransform(translationX: x, y: 0)
            
        })
        
        
    }
    
    
    
    func dismissAnimation(){
        
        
    }
    
    
    
    
    @IBAction func closeButton_TouchUpInside(_ sender: Any) {
        
        
    
       dismiss(animated: true, completion: nil)

        
//        let transition: CATransition = CATransition()
//        transition.duration = 1
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionReveal
//        transition.subtype = kCATransitionFade
//        self.view.window!.layer.add(transition, forKey: nil)
//        self.dismiss(animated: false, completion: nil)

        
    }
    

    @IBAction func addPinAndSaveLocation(_ sender: Any) {
        
       
    
        let userLocationCoordinates = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
        
        let pinForUserLocation = MGLPointAnnotation()
        
        pinForUserLocation.coordinate = userLocationCoordinates
        
        let selected = pickerView.selectedRow(inComponent: 0)
        
        guard selected > 0 else {
            print("select a type")
            return
        }
        
      guard let skateTitleText = skateTitleText.text, let skateStyleText = skateStyleText.text else { return }
    
        guard skateTitleText.characters.count > 0, skateStyleText.characters.count > 0 else {
            
            return
            
        }
        
        //When the user clicks the button, send the CLLocation Coordinate 2D make to firebase against their user ID
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        let locationsRef = FIRDatabase.database().reference().child("users").child(uid).child("personalLocations").childByAutoId()
        
        locationsRef.setValue(["lat": locationManager.location?.coordinate.latitude, "lng": locationManager.location?.coordinate.longitude, "name": skateTitleText, "subtitle": skateStyleText, "type": (selected - 1), "editable": true])
        
        
    }
    
    
    
    
    @IBAction func addButton_TouchUpInside(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
    
    }
    

}



extension SaveSpotViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
}

extension SaveSpotViewController: UIPickerViewDataSource {
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    
}

