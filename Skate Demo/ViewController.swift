//
//  ViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 15/03/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import Firebase
import Mapbox
import MapboxDirections
import MapKit

class ViewController: UIViewController, SideBarDelegate, MGLMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MGLMapView!
    

    
    
    var sideBar: SideBar = SideBar()
    
    var skateparks = [Skatepark]()
    
    var skatepark: Skatepark?
    
    var user: FIRUser!
    
    let locationManager = CLLocationManager()
    
    let locationsRef = FIRDatabase.database().reference(withPath: "locations")
    
    let directions = Directions.shared
    
    var annotation = MGLAnnotationView()
    
    var pointAnnotation = MGLPointAnnotation()
    
    //Filtering annotations for sidebar
    
    func sideBarDidSelectButtonAtIndex(_ index: Int) {
       mapView.removeAnnotations(mapView.annotations!)
        
        for park in skateparks {
            
            if index == 0 {
                addAnnotation(park: park)
            }
            
            if index == 1 && park.type == .park {
                addAnnotation(park: park)
            }
            
            if index == 2 && park.type == .street {
                addAnnotation(park: park)
            }
            
            //Change this to feature the users own personal spots they saved to firebase
            
            if index == 3 && park.type == .own {
                addAnnotation(park: park)
            }
            
            
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        
        
        let logo = UIImage(named: "SkateHeaderIcon1")
        let imageView = UIImageView(image: logo)
        self.navigationItem.titleView = imageView
        
        
        
        let SkateIcon = MGLPointAnnotation()
        mapView.addAnnotation(SkateIcon)
        

//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        imageView.contentMode = .scaleAspectFit
//        
//        let image = UIImage(named: "SNav")
//        imageView.image = image
//        navigationItem.titleView = imageView
        
        //Map
        
        
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        
        //Directions
        
        
        
       
    

        //Sidebar
        
        sideBar = SideBar(sourceView: self.view, skateItems: ["All Skate Spots", "Skateparks", "Street Skating", "Favourite Spots"])
        sideBar.delegate = self
        
        
        // Passing firebase annotation data
        
        locationsRef.observe(.value, with: { snapshot in
            self.skateparks.removeAll()
            
            for item in snapshot.children {
                guard let snapshot = item as? FIRDataSnapshot else { continue }
                
                let newSkatepark = Skatepark(snapshot: snapshot)
                
                self.skateparks.append(newSkatepark)

                self.addAnnotation(park: newSkatepark)
            }
            
            self.loadCustomLocations()
            
        })
    }
    
    func loadCustomLocations() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        let userLocationsRef = FIRDatabase.database().reference(withPath: "users/\(uid)/personalLocations")
        
        userLocationsRef.observe(.value, with: { snapshot in
            
            
            for item in snapshot.children {
                guard let snapshot = item as? FIRDataSnapshot else { continue }
                
                let newSkatepark = Skatepark(snapshot: snapshot)
                
                self.skateparks.append(newSkatepark)
                
                self.addAnnotation(park: newSkatepark)
            }
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.sendSubview(toBack: mapView)
    }
    
    
    //Adding annotations on map
    
    func addAnnotation(park: Skatepark) {

        let point = SkateAnnotation()
        
        point.coordinate = park.coordinate

        point.title = park.name
        
        point.id = park.id
        
        point.subtitle = park.subtitle
        
        point.canEdit = park.editable
        
        mapView.addAnnotation(point)
        
        mapView.selectAnnotation(point, animated: true)
        
    }
    
    
//    //User can save their location
//    @IBAction func findUserLocationAndDropPin(_ sender: UIButton) {
//        
//        let userLocationCoordinates = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
//        
//        let pinForUserLocation = MGLPointAnnotation()
//        
//        pinForUserLocation.coordinate = userLocationCoordinates
//        
//        pinForUserLocation.title = ""
//        pinForUserLocation.subtitle = ""
//        
//        mapView.addAnnotation(pinForUserLocation)
//        mapView.showAnnotations([pinForUserLocation], animated: true)
//        
//        //When the user clicks the button, send the CLLocation Coordinate 2D make to firebase against their user ID
//        
//        let uid = FIRAuth.auth()!.currentUser!.uid
//        
//        let locationsRef = FIRDatabase.database().reference().child("users").child(uid).child("personalLocations").childByAutoId()
//        
//        locationsRef.setValue(["lat": locationManager.location?.coordinate.latitude, "lng": locationManager.location?.coordinate.longitude, "name": "Test", "type": 0, "subtitle": "some subtitle"])
//        
//        
//
//    }
    
    
    
  
    //Show the annotation callout

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    
        return true
    

    }
    
    //Hide the callout view
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        
        if control.tag == 100 {
            guard let annotation = annotation as? SkateAnnotation else { return }
            
            
            self.performSegue(withIdentifier: "EditSaveSpotSegue", sender: annotation.id)
            
            
        } else if control.tag == 101 {
            
            self.performSegue(withIdentifier: "InviteUserSegue", sender: view)
            
        }
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSaveSpotSegue" {
            let destination = segue.destination as! EditSaveSpotViewController
            destination.parkId = sender as! String
        }
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        guard let skateAnnotation = annotation as? SkateAnnotation else { return nil }
       
        if skateAnnotation.canEdit {
            
            let button = UIButton(type: .detailDisclosure)
            button.tag = 100
            return button
        }
        
        return nil
        
        
    }
    

    //Information button - turn this into 360 image
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        let button = UIButton(type: .contactAdd)
        button.tag = 101
        return button
        

    }
    
    

    //Image for Annotation - Change this for Skatepark/StreetSkating
    
     func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
     //   return nil
      
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "SkateAnnotation1")
        
        if annotationImage == nil {
            
            var image = UIImage(named: "SkateAnnotation1")!
            
            
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height / 2, right: 0))
            
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "SkateAnnotation1")
            
            
            
        }
        
        return annotationImage
        
    }
    
}


