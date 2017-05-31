
import UIKit
import FSCalendar
import Firebase
import SystemConfiguration


class ShopPanelPrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var prenotationList = [Prenotation]()
    
    var ref: DatabaseReference? = nil
    
    @IBOutlet weak var updated: UILabel!
    
    @IBOutlet weak var totalReservations: UILabel!
    
    @IBOutlet weak var prenotationCollectionView: UITableView!
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
    var selectedDay: Date!
    var selectedShop: Shop!
    var selectedTime: Int = 0
    var selectedServices: [Service] = []
    var selectedDuration = 0
    var loadingAlert: UIAlertController!
    var selectedID:Int!
    var isAnEdit = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //today date
        self.hideKeyboardWhenTappedAround()
        let data = Date()
        self.selectedDay = data
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        selectedDate = formatter.string(from: data)
        
        self.calendar.scope = .week
        calendar.appearance.headerDateFormat = "MMM yyyy"
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        

        // self.view.addGestureRecognizer(self.scopeGesture)
        
        loadingAlert = Funcs.inizializeLoadAnimation()
        present(loadingAlert, animated: true, completion: nil)
        if(selectedShop == nil){
            Funcs.loadShop(){loadedShop in
                self.selectedShop = loadedShop
                self.navigationItem.title = "\(loadedShop.name) - Panel"
                self.dismiss(animated: false, completion: {self.readData()})
            }

        }
}
    
    func readData(){
        present(loadingAlert, animated: true, completion: nil)
        prenotationList.removeAll()
        self.prenotationCollectionView.reloadData()
        //FIRBASE REFERENCE
        ref = Database.database().reference().child("prenotations/\(selectedShop.ID)").child(selectedDate)
        ref?.observe(.childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let note = userDict["note"] as? String ?? "test"
                let user = userDict["user"] as? String ?? "NoName"
                let time = userDict["time"] as? Int ?? 0
                let reservationID = snapshot.key
                var bookedServices : [Service] = []
                if let child = snapshot.childSnapshot(forPath: "services").value as? [String:Any] {
                    for c in child{
                        if let tempServiceChild = c.value as? [String:Any]{
                            let serviceName = tempServiceChild["type"] as? String ?? "NoName"
                            let serviceDuration = tempServiceChild["duration"] as? Int ?? 0
                            let servicePrice = tempServiceChild["price"] as? Int ?? 0
                            let id = tempServiceChild["id"] as? String ?? "NOID"

                            bookedServices.append(Service(name: serviceName, duration: serviceDuration, price: servicePrice, id: id))
                        }
                    }
                }
                self.prenotationList.append(Prenotation(customerName: user, service: bookedServices, timeInMinute: time, note: note, id: reservationID))
                self.prenotationList = self.prenotationList.sorted(by: { $0.timeInMinute < $1.timeInMinute })
                
                self.prenotationCollectionView.reloadData()
                self.totalReservations.text = String(self.prenotationList.count)
            }})
        
        
        // UPDATED AT
        
        self.dismiss(animated: false, completion: nil)
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
        self.selectedDay = date
        self.readData()
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    @IBAction func addPrenotation(_ sender: UIBarButtonItem) {
        self.isAnEdit = false
        performSegue(withIdentifier: "addItem", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return prenotationList.count


    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let ref2 = Database.database().reference()
            var totalReservation = 0
            var nameReservation = ""
            var totalDuration = 0
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReservation", for: indexPath) as!  ReservationMerchantTableViewCell
            
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
            
            cell.name.text = ""
            cell.number.text = ""
            ref2.child("user").child(prenotationList[indexPath.row].customerName).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                if let value = snapshot.value as? NSDictionary {
                    var userName = value["name"] as? String ?? ""
                    //TODO: Gestire meglio il nome come note
                    if(self.prenotationList[indexPath.row].note != "test" &&
                        self.prenotationList[indexPath.row].note != "" &&
                        self.prenotationList[indexPath.row].note != "NoNote" &&
                        self.prenotationList[indexPath.row].note != "noNote" &&
                        self.prenotationList[indexPath.row].note != " " ){
                        userName  = self.prenotationList[indexPath.row].note
                    }
                    cell.name.text = userName
                    cell.number.text = value["phone"] as? String ?? ""
                    
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            cell.time.text = "\(Funcs.minutesToHour(prenotationList[indexPath.row].timeInMinute)) - \(Funcs.minutesToHour(prenotationList[indexPath.row].timeInMinute + totalDuration))"
            cell.services.text = nameReservation
            cell.duration.text = "Duration: \(totalDuration) Min"
            return cell

    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isAnEdit = true
        self.selectedID = indexPath.row
        performSegue(withIdentifier: "addItem", sender: nil)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let cancel = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let DestructiveAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                self.selectedID = indexPath.row
                self.removeReservation()
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tableView.reloadData()
            }
            
            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        cancel.backgroundColor = .red
        return  [cancel]
    }
    func removeReservation(){
        let ref = Database.database().reference()
        ref.child("prenotations/\(selectedShop.ID)/\(selectedDate)/\(self.prenotationList[selectedID!].id)").removeValue()
       self.prenotationList.remove(at: selectedID!)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailBarber = segue.destination as? MerchantPrenotationViewController{
            if(isAnEdit){
                detailBarber.selectedShop = self.selectedShop
                detailBarber.selectedDate = self.selectedDay
                detailBarber.currentReservation = self.prenotationList[selectedID!]
                detailBarber.isAnEdit = true
                
            }else{
                detailBarber.selectedShop = self.selectedShop
                detailBarber.selectedDate = self.selectedDay
                detailBarber.isAnEdit = false
            }
        }
        if let detailBarber = segue.destination as? MerchantDetailViewController{
            detailBarber.selectedShop = self.selectedShop
            MerchantProfileViewController.myShop = self.selectedShop
            
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
