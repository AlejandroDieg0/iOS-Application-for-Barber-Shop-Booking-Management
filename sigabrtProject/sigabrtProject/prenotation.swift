//
//  Service.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//
import Foundation
import UIKit

var prenotationList = [prenotation]()

class prenotation {
    
    let customerName: String
    let tipoServizio: String
    let prezzoServizio : Int
    let timeSelected: String
    
    init(customerName: String, tipoServizio: String, prezzoServizio: Int, timeSelected: String){
        self.customerName = customerName
        self.tipoServizio = tipoServizio
        self.prezzoServizio = prezzoServizio
        self.timeSelected = timeSelected
    }
}
