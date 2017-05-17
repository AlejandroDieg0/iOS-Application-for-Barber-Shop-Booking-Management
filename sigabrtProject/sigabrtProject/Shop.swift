//
//  Shop.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit
import MapKit

class Shop: NSObject , MKAnnotation {
    let barberId: Int = -1
    var name: String = ""
    let services: [Int] = [] //dovrebbe essere un array di service ma non funziona
    let numBarbers: Int = -1
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var desc: String = ""
    
    init(name : String, desc : String, coordinate: CLLocationCoordinate2D){
        
        self.name = name
        self.desc = desc
        self.coordinate = coordinate
        
    }
}
