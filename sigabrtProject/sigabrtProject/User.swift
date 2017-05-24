//
//  Utente.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String = ""
    var mail: String = ""
    var phone: String = ""
    var userType: Int = -1
    var favBarberId: Int = -1
    
    init(name: String,     mail: String,     phone: String,     userType: Int,     favBarberId: Int){
        self.name =  name
        self.mail =  mail
        self.phone =  phone
        self.userType = userType
        self.favBarberId =  favBarberId
    }
}
