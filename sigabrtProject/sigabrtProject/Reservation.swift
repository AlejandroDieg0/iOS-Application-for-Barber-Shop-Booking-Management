//
//  Reservation.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class Reservation: NSObject {
    var Id: Int = -1
    var userId: Int = -1
    var shopId: Int = -1
    var serviceId: [Int] = []
    var dateTime: Date = Date()
    
    init(Id: Int, userId : Int, shopId : Int, serviceId: [Int], dateTime: Date){
        self.Id=Id
        self.userId=userId
        self.shopId=shopId
        self.serviceId=serviceId
        self.dateTime=dateTime
    }
}
