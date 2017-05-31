
import Foundation
import UIKit

var prenotationList = [Prenotation]()

class Prenotation {
    
    let customerName: String
    let service: [Service]
    let timeInMinute: Int
    let note: String
    let id: String
    
    init(customerName: String, service: [Service], timeInMinute: Int, note: String, id: String){
        self.customerName = customerName
        self.service = service
        self.timeInMinute = timeInMinute
        self.note = note
        self.id = id
    }
}
