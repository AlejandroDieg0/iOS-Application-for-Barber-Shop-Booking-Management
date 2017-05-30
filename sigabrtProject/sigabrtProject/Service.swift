
import Foundation
import UIKit

var serviceList = [Service]()

class Service {
    
    let name: String
    let duration: Int
    let price: Int
    let id: String

    
    init(name: String, duration: Int, price: Int, id: String){
        self.price = price
        self.name = name
        self.duration = duration
        self.id = id
    }
}
