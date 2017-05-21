//
//  Service.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//
import Foundation
import UIKit

var serviceList = [Service]()

class Service {
    
    let name: String
    let duration: Int
    let service : Dictionary<String, String>
    
    init(name: String, duration: Int, service: Dictionary<String, String>){
        self.name = name
        self.duration = duration
        self.service = service
    }
}
