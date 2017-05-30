
import Foundation
import UIKit

var serviceList = [Service]()

class Service {
    
    var name: String
    var duration: Int
    var price: Int
    var id: String

    
    init(name: String, duration: Int, price: Int, id: String){
        self.price = price
        self.name = name
        self.duration = duration
        self.id = id
    }
}
