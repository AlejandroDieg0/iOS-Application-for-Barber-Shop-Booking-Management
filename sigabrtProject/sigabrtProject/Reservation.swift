//
//  Reservation.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 15/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class Reservation: NSObject {
    let Id: Int = -1
    let userId: Int = -1
    let shopId: Int = -1
    let serviceId: [Int] = []
    let dateTime: Date = Date()
    
    init(Id: Int, userId : Int, shopId : Int, serviceId: [Int], dateTime: Date){
        self.Id=Id
        self.userId=userId
        self.shopId=shopId
        self.serviceId=serviceId
        self.dateTime=dateTime
    }
}
