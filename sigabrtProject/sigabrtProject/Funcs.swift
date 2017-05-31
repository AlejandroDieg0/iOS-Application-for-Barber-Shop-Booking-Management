import UIKit
import Firebase
import FBSDKLoginKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class Funcs: NSObject {
    static var loggedUser : User!
    static let ref = Database.database().reference()
    static var flagFavBarber : Int = -1
    static let slotSizeInMinutes = 15
    static var bookableSlotsInMinutes: [Int] = []
    static var tempPoupupView: UIView!
    
    static func animateIn(sender: UIView) {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = topController.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.contentView.alpha = 0

            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            tempPoupupView=sender
            
            topController.view.addSubview(blurEffectView)
            blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped(sender:))))
            sender.center = topController.view.center
            topController.view.addSubview(sender)
            
            sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
            UIView.animate(withDuration: 0.4) {
                sender.alpha = 0.80
                //controller.visualEffect.alpha = 0.5
                sender.transform = CGAffineTransform.identity
            }
        }
    }
    
    static func tapped(sender: UIGestureRecognizer){
        Funcs.animateOut(sender: tempPoupupView)
    }
    
    static func animateOut (sender: UIView) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            for tempView in topController.view.subviews{
                if let blurView = tempView as? UIVisualEffectView{
                    UIView.animate(withDuration: 0.4) {
                        blurView.alpha = 0
                    }
                    blurView.removeFromSuperview()
                }
            }
            UIView.animate(withDuration: 0.4, animations: {
                sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                sender.alpha = 0
                
            }) { (success:Bool) in
                sender.removeFromSuperview()
            }
        }
    }
    
    static func inizializeLoadAnimation() -> UIAlertController{
        let AlertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        
        AlertController.view.addSubview(loadingIndicator)
        return AlertController
    }
    
    static func addReservation(shop: Shop, time: Int, note: String?, services: [Service], date: Date, completion: @escaping () -> Void){
        let ref: DatabaseReference = Database.database().reference()
        
        let reservationDate = date.toString(format: "yy-MM-dd")
        
        print(reservationDate)
        let post = [
            "user":  Auth.auth().currentUser!.uid,
            "time":  time,
            "note": note ?? "Not inserted"
            ] as [String : Any]
        
        let key = ref.child("prenotations/\(shop.ID)/\(reservationDate)/").childByAutoId().key
        
        ref.child("prenotations/\(shop.ID)/\(reservationDate)/").child(key).setValue(post)
        
        for service in services {
            let post = ["price": service.price,
                        "type": service.name,
                        "duration": service.duration] as [String : Any]
            ref.child("prenotations/\(shop.ID)/\(reservationDate)/\(key)/services").childByAutoId().setValue(post)
            completion()
        }
    }
    static func editReservation(shop: Shop, time: Int, services: [Service], date: Date, oldReservation: Prenotation, completion: @escaping () -> Void){
        var newTime:Int!
        
        if(time == 0 ){
            newTime = oldReservation.timeInMinute
        }else{
            newTime = time
        }

        let ref: DatabaseReference = Database.database().reference()
        
        let reservationDate = date.toString(format: "yy-MM-dd")
        
        print(reservationDate)
        let post = [
            "user":  oldReservation.customerName,
            "time":  newTime,
            "note": oldReservation.note
            ] as [String : Any]
        
        let key = ref.child("prenotations/\(shop.ID)/\(reservationDate)/").childByAutoId().key
        
        ref.child("prenotations/\(shop.ID)/\(reservationDate)/").child(key).setValue(post)
        
        for service in services {
            let post = ["price": service.price,
                        "type": service.name,
                        "duration": service.duration] as [String : Any]
            ref.child("prenotations/\(shop.ID)/\(reservationDate)/\(key)/services").childByAutoId().setValue(post)
        }
        let ref2 = Database.database().reference()
        ref2.child("prenotations/\(shop.ID)/\(reservationDate)/\(oldReservation.id)").removeValue()
        completion()
    }

    static func loadUserData(completion: @escaping (_ result: User) -> Void){
        let user = Auth.auth().currentUser
        if (user == nil) {return}
        let ref = Database.database().reference().child("user").child(user!.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let phone = value["phone"] as? String ?? ""
                let name = value["name"] as? String ?? ""
                let favBarber = value["favbarber"] as? Int ?? -1
                let userType = value["usertype"] as? Int ?? 0
                let mail = user?.email
                print("phone \(phone)")
                self.loggedUser = User(name: name, mail: mail!, phone: phone, userType: userType, favBarberId: favBarber)
                completion(self.loggedUser)
            } else {
                let ref: DatabaseReference = Database.database().reference()
                
                if(FBSDKAccessToken.current() != nil){
                    let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email,picture.type(large)"])
                    
                    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                        
                        if ((error) != nil)
                        {
                            print("Error: \(String(describing: error))")
                        }
                        else
                        {
                            let data:[String:AnyObject] = result as! [String : AnyObject]
                            let fbname = data["name"] as? String ?? ""
                            let post = [
                                "name":  fbname,
                                "phone": "",
                                "favbarber": Funcs.flagFavBarber,
                                "usertype": 0,
                                ] as [String : Any]
                            
                            ref.setValue(post)
                            self.loggedUser = User(name: fbname, mail: "", phone: "", userType: 0, favBarberId: Funcs.flagFavBarber)
                            completion(self.loggedUser)
                        }
                    })
                } else {
                    let post = [
                        "name":  "",
                        "phone": "",
                        "favbarber": Funcs.flagFavBarber,
                        "usertype": 0,
                        ] as [String : Any]
                    
                    ref.setValue(post)
                    self.loggedUser = User(name: "", mail: "", phone: "", userType: 0, favBarberId: Funcs.flagFavBarber)
                    completion(self.loggedUser)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
//    static func getUserNameByUID(uid: String, textLabel: UILabel) -> String {
//        var name = ""
//        ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            if let value = snapshot.value as? NSDictionary {
//                name = value["name"] as? String ?? ""
//                textLabel.text = name
//                print(name)
//            }
//        }) { (error) in
//            print(error.localizedDescription)
//            name = "NoName"
//        }
//        print("the name is \(name)")
//        return name
//
//    }
    
    static func loadShop(completion: @escaping (_ result: Shop) -> Void){
        ref.child("barbers").child(String(self.loggedUser.favBarberId)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get shop description
            if let value = snapshot.value as? NSDictionary {
                let barberName = value["name"] as? String ?? "NoName"
                let barberDesc = value["description"] as? String ?? "NoDesc"
                let barberPhone = value["phone"] as? String ?? "NoPhone"
                let barberAddress = (value["address"])! as? String ?? "NoAddress"
                var barberServices:[Service] = []
                if let child = snapshot.childSnapshot(forPath: "services").value as? [String:Any] {
                    for c in child{
                        if let smallChild = snapshot.childSnapshot(forPath: "services/\(c.key)").value as? [String:Any]  {
                            let id = c.key
                            let serviceName = smallChild["name"] as? String ?? "NoName"
                            let serviceDuration = smallChild["duration"] as? Int ?? 0
                            let servicePrice = smallChild["price"] as? Int ?? 0
                            let service = Service(name: serviceName, duration: serviceDuration, price: servicePrice, id: id)
                            barberServices.append(service)
                            
                        }
                    }
                }
                var hours : [String:[[Int]]] = [:]
                if let child = snapshot.childSnapshot(forPath: "hours").value as? [String:Any]  {
                    
                    for c in child{
                        hours[c.key] = []
                        if let smallChild = snapshot.childSnapshot(forPath: "hours/\(c.key)").value as? NSArray  {
                            for smallC in smallChild{
                                if let tempTime = smallC as? [String:Any]{
                                    
                                    let open = tempTime["open"] as? Int ?? 0
                                    let close = tempTime["close"] as? Int ?? 0
                                    
                                    hours[c.key]?.append([open,close])
                                    
                                }
                            }
                        }
                    }
                }
                completion(Shop(ID: self.loggedUser.favBarberId, name: barberName, desc: barberDesc, phone: barberPhone, address: barberAddress, services: barberServices, hours: hours))
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func setFavourite(_ shopid: Int){
        Funcs.flagFavBarber = shopid
        if Auth.auth().currentUser != nil {
            var ref: DatabaseReference!
            ref = Database.database().reference().child("user/\((Auth.auth().currentUser?.uid)!)")
            let post = ["favbarber": shopid]
            ref.updateChildValues(post)
            Funcs.loggedUser.favBarberId = shopid
        }
    }
    
    static func busySlots(shop: Shop, date: Date, duration: Int, collection: UICollectionView) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        let selectedDay = dateFormatter.string(from: date)
        var busySlots : [Int] = []
        var prenotationDuration = 0
        let prenotationChild = self.ref.child("prenotations").child(String(shop.ID)).child(selectedDay)
        prenotationChild.observe(.childAdded, with: { (snapshot) in
            if let prenotationDict = snapshot.value as? [String:Any] {
                let time = prenotationDict["time"] as? Int ?? 0
                if let servicesChild = snapshot.childSnapshot(forPath: "services").value as? [String:Any] {
                    prenotationDuration = 0
                    for c in servicesChild{
                        if let tempServiceChild = c.value as? [String:Any]{
                            let serviceDuration = tempServiceChild["duration"] as? Int ?? 0
                            prenotationDuration = prenotationDuration + serviceDuration - 1
                        }
                    }
                            for slot in time ... time + prenotationDuration{
                                if(!busySlots.contains(slot)){
                                    busySlots.append(slot)
                                }
                            }
                }
                
                self.calcSlots(shop: shop, day: date, busySlots: busySlots, duration: duration, collection: collection)
            }})
        self.calcSlots(shop: shop, day: date, busySlots: busySlots, duration: duration, collection: collection)
        
    }
    
    static func calcSlots(shop: Shop, day: Date, busySlots: [Int], duration: Int, collection: UICollectionView) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.full
        // let test = dateFormatter.string(from: date)
        bookableSlotsInMinutes = []
        let selectedDay = dateFormatter.string(from: day).components(separatedBy: ",")
        let slotsInADay = 1440
        var serviceDuration : Int!
        if(duration != 0){
            serviceDuration = duration - 1
        }else{
            serviceDuration = duration
        }
        for currslot in 300 ... slotsInADay {
            let currentSlotMinute = currslot
            if let arrayDay = shop.hours?[selectedDay[0]]{
                for shopOpeningFrame in arrayDay {
                    //TODO: bisogna aggiungere a currentSlotMinute la durata del servizio (dei servizi) selezionati
                    if (currentSlotMinute >= shopOpeningFrame[0] &&
                        currentSlotMinute < shopOpeningFrame[1] &&
                        !busySlots.contains(currentSlotMinute) &&
                        currentSlotMinute % 5 == 0){
                            var bookable = true
                                for slot in currentSlotMinute - 15 ... currentSlotMinute{
                                    if(bookableSlotsInMinutes.contains(slot)){
                                        bookable = false
                                    }
                                }
                                for slot in currentSlotMinute ... currentSlotMinute + serviceDuration!{
                                    if(busySlots.contains(slot)){
                                        bookable = false
                                    }
                            }
                          if(bookable){
                            bookableSlotsInMinutes.append(currentSlotMinute)
                        }
                    }
                }
            }
        }
        collection.reloadData()
    }
    
    static func minutesToHour(_ minutes: Int) -> String {
        return "\(String(format: "%02d", minutes/60)):\(String(format: "%02d", minutes%60))"
    }
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
