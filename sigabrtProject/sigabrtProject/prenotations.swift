//
//  prenotations.swift
//  sigabrtProject
//
//  Created by Fabio on 20/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import Foundation
import UIKit

class prenotations {
    
    var name : String
    var time : String
    var service : [String: String] = [:]
    
    init(name: String, time: String , service: [String: String]) {
        self.name = name
        self.time = time
        self.service = service
    }
}
