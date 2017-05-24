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
    let tipoServizio: String
    let prezzoServizio : Int
    let timeInMinute: Int
    
    init(customerName: String, tipoServizio: String, prezzoServizio: Int, timeInMinute: Int){
        self.customerName = customerName
        self.tipoServizio = tipoServizio
        self.prezzoServizio = prezzoServizio
        self.timeInMinute = timeInMinute
    }
}
