
import UIKit
import FSCalendar
import Firebase
import SystemConfiguration


class BarberPagePrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var prenotationList = [Prenotation]()
    
    var ref: DatabaseReference? = nil
    
    @IBOutlet weak var updated: UILabel!
    
    @IBOutlet weak var totalReservations: UILabel!
    
    @IBOutlet weak var freeTimeSlotCollectionView: UICollectionView!
    @IBOutlet weak var prenotationCollectionView: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    
    var selectedDate = ""
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
    var selectedShop: Shop!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //today date
        let data = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        selectedDate = formatter.string(from: data)
        
        self.calendar.scope = .week
        calendar.appearance.headerDateFormat = "MMM yyyy"
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        freeTimeSlotCollectionView.delegate = self
        freeTimeSlotCollectionView.dataSource = self
        prenotationCollectionView.delegate = self
        prenotationCollectionView.dataSource = self
        
        self.view.addGestureRecognizer(self.scopeGesture)
        
        Funcs.loadShop(){loadedShop in
            self.selectedShop = loadedShop
            Funcs.busySlots(shop: loadedShop, date: data, duration: 0, collection: self.freeTimeSlotCollectionView)
            self.readData()
        }
    }
    
    
    func readData(){
        prenotationList.removeAll()
        self.prenotationCollectionView.reloadData()
        //FIRBASE REFERENCE
        ref = Database.database().reference().child("prenotations/\(selectedShop.ID)").child(selectedDate)
        ref?.observe(.childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let note = userDict["note"] as? String ?? "test"
                let user = userDict["user"] as? String ?? "NoName"

                let time = userDict["time"] as? Int ?? 0
                var bookedServices : [Service] = []
                if let child = snapshot.childSnapshot(forPath: "services").value as? [String:Any] {
                    print(child)
                    for c in child{
                        if let tempServiceChild = c.value as? [String:Any]{
                            let serviceName = tempServiceChild["type"] as? String ?? "NoName"
                            let serviceDuration = tempServiceChild["duration"] as? Int ?? 0
                            let servicePrice = tempServiceChild["price"] as? Int ?? 0
                            bookedServices.append(Service(name: serviceName, duration: serviceDuration, price: servicePrice))
                            print(serviceName)
                        }
                    }
                }
                self.prenotationList.append(Prenotation(customerName: user, service: bookedServices, timeInMinute: time, note: note))
                
                self.prenotationCollectionView.reloadData()
                self.totalReservations.text = String(self.prenotationList.count)
            }})
        
        
        // UPDATED AT
        
        let x = isInternetAvailable()
        if x == true{
            self.updated.textColor = UIColor.darkGray
            self.updated.text = "updated at \( Date().toString(format:"HH:mm"))"
        }
        else{
            self.updated.textColor = UIColor.red
            self.updated.text = "no internet connection"
            
        }
        
        
        
        
        self.totalReservations.text = String(self.prenotationList.count)
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        
        self.selectedDate = self.dateFormatter.string(from: date)
        self.readData()
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    @IBAction func addPrenotation(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addItem", sender: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.prenotationCollectionView {
            return prenotationList.count
            
        } else {
            return Funcs.bookableSlotsInMinutes.count
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.prenotationCollectionView {

            let ref2 = Database.database().reference()
            var totalReservation = 0
            var nameReservation = ""
            var totalDuration = 0
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!  CollectionViewCell
            
            for service in prenotationList[indexPath.row].service{
                totalReservation = service.price + totalReservation
                if (nameReservation != ""){
                    nameReservation = nameReservation + ", " + service.name
                }else{
                    nameReservation = service.name
                }
                totalDuration = totalDuration + service.duration
            }
            cell.total.text = String(totalReservation) + " €"
            
            ref2.child("user").child(prenotationList[indexPath.row].customerName).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                if let value = snapshot.value as? NSDictionary {
                    let userName = value["name"] as? String ?? ""
                    cell.name.text = userName
                    
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            cell.time.text = Funcs.minutesToHour(prenotationList[indexPath.row].timeInMinute)
            cell.services.text = nameReservation
            cell.number.text = "Duration: \(totalDuration) Min"
            return cell
        } else {
            let cell = freeTimeSlotCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! freeTimeBarberCollectionViewCell
            cell.label.text = Funcs.minutesToHour(Funcs.bookableSlotsInMinutes[indexPath.row])
            
            return cell
        }
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
