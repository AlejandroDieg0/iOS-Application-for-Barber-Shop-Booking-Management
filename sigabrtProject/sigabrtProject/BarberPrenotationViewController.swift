
import UIKit
import FSCalendar
import Firebase

class BarberPrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
  
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var servicesTableView: UITableView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var freeTimeSlotCollectionView: UICollectionView!
    var ref: DatabaseReference!
    
    var selectedDate = ""
    var selectedTimeInMinutes: Int!
    var services: [Service] = []
    var selectedServices : [Service] = []
    
    var selectedTipo: [String] = []
    var selectedPrezzo : [Int] = []
    var timeSlot: [String] = []
    var timeSlotInMinutes : [Int] = []
    let slotSizeInMinutes = 15
    
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        //TODO: Capire come cazzo fare per far scomparire la tastiere senza rompere tutto 
        
        //self.hideKeyboardWhenTappedAround()
        
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

        //TODO: leggere il weekday
        calcSlots(day: data)
        
        //self.time.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        servicesTableView.allowsMultipleSelection = true
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        
        readData()
        
        self.calendar.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)

    }
    
    func readData(){
        //service.removeAll()
        self.servicesTableView.reloadData()
        //FIRBASE REFERENCE
        var ref: DatabaseReference!
        ref = Database.database().reference().child("barbers/\(String(Funcs.loggedUser.favBarberId))/services")
        
        ref?.observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {
                print("null")
            }
            
            if let snapshotValue = snapshot.value as? [String:Any] {
                let tipo = (snapshotValue["name"])! as! String
                let price = (snapshotValue["price"])! as! Int
                let duration = (snapshotValue["duration"])! as! Int
                
                self.services.append(Service(name: tipo, duration: duration, price: price))
                self.servicesTableView.reloadData()
            }})
    }
    
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
//        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
//        print("selected dates is \(selectedDates)")
        self.selectedDate = self.dateFormatter.string(from: date)
        print(selectedDate)
        
        //TODO: richiamare calcSlots
        self.calcSlots(day: date)
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "OK", style: .default) { action in
            let customerName = self.name.text
            //FIRBASE REFERENCE
            let ref: DatabaseReference = Database.database().reference()
            
            let post = [
                "user":  self.user!.uid,
                "time":  self.selectedTimeInMinutes,
                "note": customerName ?? "Not inserted"
                ] as [String : Any]
            
            let key = ref.child("prenotations/1/\(self.selectedDate)/").childByAutoId().key
            
            ref.child("prenotations/1/\(self.selectedDate)/").child(key).setValue(post)
            
            for service in self.selectedServices {
                let post = [        "price": service.price,
                                    "type": service.name,
                                    "duration": service.duration] as [String : Any]
                ref.child("prenotations/1/\(self.selectedDate)/\(key)/services").childByAutoId().setValue(post)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion:  nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = servicesTableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! addModifyCollectionViewCell
        cell.servizio.text = services[indexPath.row].name
        cell.price.text = String(services[indexPath.row].price) + "€"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedServices.append(services[indexPath.row])
    }
    
    // PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTimeInMinutes = timeSlotInMinutes[indexPath.row]
        print(selectedTimeInMinutes)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeSlot.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! freeTimeBarberCollectionViewCell
        cell.label.text = timeSlot[indexPath.row]
        return cell
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func calcSlots(day: Date) {
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.full
        // let test = dateFormatter.string(from: date)
        timeSlot = []
        timeSlotInMinutes = []
        let selectedDay = dateFormatter.string(from: day).components(separatedBy: ",")
        print(selectedDay[0])
        let slotsInADay = 1440 / slotSizeInMinutes
        
        for currslot in 0 ... slotsInADay {
            let currentSlotMinute = currslot * slotSizeInMinutes
            if let arrayDay = (Funcs.currentShop.hours?[selectedDay[0]]){
                for shopOpeningFrame in arrayDay {
                    //TODO: bisogna aggiungere a currentSlotMinute la durata del servizio (dei servizi) selezionati
                    var isBookable = false
                    if (currentSlotMinute >= shopOpeningFrame[0] && currentSlotMinute < shopOpeningFrame[1]){
                        isBookable = true
                    }
                    //TODO: ulteriore if per controllare che currentSlotMinute non sia già nell'array delle prenotazioni (non sia già prenotato)
                    if (isBookable){
                        timeSlotInMinutes.append(currentSlotMinute)
                        timeSlot.append("\(currentSlotMinute/60):\(currentSlotMinute%60)")
                    }
                }
            }

        }
    freeTimeSlotCollectionView.reloadData()
    }
}

