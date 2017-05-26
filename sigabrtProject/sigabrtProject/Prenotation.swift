//
//  Service.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//
import Foundation
import UIKit

var prenotationList = [Prenotation]()

class Prenotation {
    
    let customerName: String
    let service: [Service]
    let timeInMinute: Int
    let note: String
    
    init(customerName: String, service: [Service], timeInMinute: Int, note: String){
        self.customerName = customerName
        self.service = service
        self.timeInMinute = timeInMinute
        self.note = note
    }
}
