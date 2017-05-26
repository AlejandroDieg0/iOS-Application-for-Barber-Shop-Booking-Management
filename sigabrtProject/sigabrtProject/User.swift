

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
