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
    
    let id: Int
    let name: String
    let duration: Int
    let price: Int
    
    init(name: String, duration: Int, id: Int, price: Int){
        self.id = id
        self.price = price
        self.name = name
        self.duration = duration
    }
}
