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
    let prezzoServizio : [String]
    let timeSelected: String
    let total: Int
    
    init(customerName: String, tipoServizio: String,prezzoServizio: [String], timeSelected: String, total: Int){
        self.customerName = customerName
        self.tipoServizio = tipoServizio
        self.prezzoServizio = prezzoServizio
        self.timeSelected = timeSelected
        self.total = total
    }
}
