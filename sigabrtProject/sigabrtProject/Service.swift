
import Foundation
import UIKit

var serviceList = [Service]()

class Service {
    
    let name: String
    let duration: Int
    let price: Int
    
    init(name: String, duration: Int, price: Int){
        self.price = price
        self.name = name
        self.duration = duration
    }
}
