
import UIKit
import FSCalendar
import Firebase
import SystemConfiguration


class ShopPanelPrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    
    var prenotationList = [Prenotation]()
    
    var ref: DatabaseReference? = nil
    
    @IBOutlet weak var updated: UILabel!
    
    @IBOutlet weak var totalReservations: UILabel!
    
    @IBOutlet weak var freeTimeSlotCollectionView: UICollectionView!
    @IBOutlet weak var prenotationCollectionView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editReservationTableView: UITableView!

    @IBOutlet var editReservationView: UIView!
    @IBOutlet weak var editReservationSlotsCollectionView: UICollectionView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //today date
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
        
        freeTimeSlotCollectionView.delegate = self
        freeTimeSlotCollectionView.dataSource = self
        
        editReservationTableView.delegate = self
        editReservationTableView.dataSource = self
        
        editReservationSlotsCollectionView.delegate = self
        editReservationSlotsCollectionView.dataSource = self
        
        // self.view.addGestureRecognizer(self.scopeGesture)
        
        loadingAlert = Funcs.inizializeLoadAnimation()
        present(loadingAlert, animated: true, completion: nil)
        if(selectedShop == nil){
            Funcs.loadShop(){loadedShop in
                self.selectedShop = loadedShop
                Funcs.busySlots(shop: loadedShop, date: data, duration: 0, collection: self.freeTimeSlotCollectionView)
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
        performSegue(withIdentifier: "addItem", sender: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Funcs.bookableSlotsInMinutes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == editReservationSlotsCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! freeTimeBarberCollectionViewCell
            cell.label.text = Funcs.minutesToHour(Funcs.bookableSlotsInMinutes[indexPath.row])
            
            let iPath = self.editReservationSlotsCollectionView.indexPathsForSelectedItems!
            if (iPath != []){
                let path : NSIndexPath = iPath[0] as NSIndexPath
                let rowIndex = path.row
                if (rowIndex == indexPath.row ){
                    cell.contentView.backgroundColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)
                    
                }else{
                    cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
                    
                }
                
            }else{
                cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            }
            
            return cell
        }
        else{
            let cell = freeTimeSlotCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! freeTimeBarberCollectionViewCell
            cell.label.text = Funcs.minutesToHour(Funcs.bookableSlotsInMinutes[indexPath.row])
            
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == editReservationSlotsCollectionView){
            self.selectedTime = Funcs.bookableSlotsInMinutes[indexPath.row]
            
            for cell in self.editReservationSlotsCollectionView.visibleCells{
                
                cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            }
            
            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)
            
            print(self.selectedTime)
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == editReservationTableView){
            return self.selectedServices.count

        }else{
            return prenotationList.count

        }
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if( tableView == editReservationTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "editReservation", for: indexPath) as!  EditReservationTableViewCell
            cell.serviceDuration.text = String(prenotationList[selectedID!].service[indexPath.row].duration) + " Min"
            cell.serviceName.text = prenotationList[selectedID!].service[indexPath.row].name
            return cell
            
        }else{
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
                    let userName = value["name"] as? String ?? ""
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

    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if( tableView == editReservationTableView){
            let cancel = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                self.selectedDuration = self.selectedDuration - self.prenotationList[self.selectedID!].service[indexPath.row].duration
                self.selectedServices = self.selectedServices.filter { $0.name != self.prenotationList[self.selectedID!].service[indexPath.row].name }
                Funcs.busySlots(shop: self.selectedShop, date: self.selectedDay, duration: self.selectedDuration, collection: self.editReservationSlotsCollectionView)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tableView.reloadData()
                
            }
            cancel.backgroundColor = .red
            return [cancel]
            
        }else{
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.selectedServices = self.prenotationList[indexPath.row].service
            self.selectedID = indexPath.row
            for service in self.prenotationList[indexPath.row].service{
                 self.selectedDuration =  self.selectedDuration + service.duration
            }
            Funcs.busySlots(shop: self.selectedShop, date: self.selectedDay, duration: self.selectedDuration, collection: self.editReservationSlotsCollectionView)
            Funcs.animateIn(sender: self.editReservationView)
      }
        edit.backgroundColor = .blue
        let cancel = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.selectedID = indexPath.row
            self.removeReservation()
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            
        }
        cancel.backgroundColor = .red
        return [edit,cancel]
        }
    }
    func removeReservation(){
        let ref = Database.database().reference()
        ref.child("prenotations/\(selectedShop.ID)/\(selectedDate)/\(self.prenotationList[selectedID!].id)").removeValue()
       self.prenotationList.remove(at: selectedID!)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailBarber = segue.destination as? MerchantPrenotationViewController{
            detailBarber.selectedShop = self.selectedShop
            detailBarber.selectedDate = self.selectedDay
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
    @IBAction func cancelEdit(_ sender: Any) {
    Funcs.animateOut(sender: self.editReservationView)
    }
    
    @IBAction func updateReservation(_ sender: Any) {
        Funcs.editReservation(shop: selectedShop, time: self.selectedTime, services: self.selectedServices, date: self.selectedDay, oldReservation: self.prenotationList[selectedID])
        Funcs.animateOut(sender: self.editReservationView)
        self.readData()
    }
}

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
