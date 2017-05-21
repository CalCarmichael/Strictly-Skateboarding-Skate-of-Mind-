//
//  Skatepark.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 22/03/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation


enum SkateType: Int {
    case park = 0, street, own
    
    func getString() -> String {
        switch self {
        case .own:
            return "Favourite Spots"
        case .street:
            return "Street Skating"
        case .park:
            return "Skatepark"
        default:
            return "Street Skating"
        }
    }
    
}



class Skatepark {
    
    let coordinate: CLLocationCoordinate2D!
    var name: String!
    var subtitle: String!
    var type: SkateType
    var editable: Bool!
    var id: String!
    var ref: FIRDatabaseReference?
    
    init(snapshot: FIRDataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: Any]
        
        id = snapshot.key
        ref = snapshot.ref
        name = snapshotValue["name"] as! String
        subtitle = snapshotValue["subtitle"] as! String
        coordinate = CLLocationCoordinate2D(latitude: snapshotValue["lat"] as! Double, longitude: snapshotValue["lng"] as! Double)
        type = SkateType(rawValue: snapshotValue["type"] as! Int)!
        editable = snapshotValue["editable"] as! Bool
        
    
    }
    
    
    
//    init(name: String, subtitle: String, key: String = "")
//    {
//        
//        
//        self.name = name
//        self.subtitle = subtitle
//        self.id = key
//        self.ref = FIRDatabase.database().reference()
//        
//    }


//    var dictionary: [String:Any]
//    {
//        return
//            [
//                "lat": coordinate.latitude,
//                "lng": coordinate.longitude,
//                "name": name,
//                "subtitle": subtitle,
//                "type": type,
//                "editable": editable
//        ]
//    }
//    
//    

    func dictionaryValues() -> [String: Any] {
        
        var data = [String: Any]()
        
        data = [
            "lat": coordinate.latitude,
            "lng": coordinate.longitude,
            "name": name,
            "subtitle": subtitle,
            "type":type.rawValue,
            "editable": editable
        ]
        
        return data
        
    }

}



