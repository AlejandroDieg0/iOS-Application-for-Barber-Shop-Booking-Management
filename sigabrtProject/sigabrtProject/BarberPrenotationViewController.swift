
import UIKit
import FSCalendar
import Firebase

class BarberPrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var servicesTableView: UITableView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var freeTimeSlotCollectionView: UICollectionView!
    
    var selectedDate : Date = Date()
    var selectedTimeInMinutes: Int!
    var services: [Service] = []
    var selectedServices : [Service] = []
    
    var selectedTipo: [String] = []
    var selectedPrezzo : [Int] = []
    
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
        
        self.hideKeyboardWhenTappedAround()
        
        let data = selectedDate
        
        self.calendar.scope = .week
        calendar.appearance.headerDateFormat = "MMM yyyy"
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        busySlots(date: data)
        
        //self.time.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        servicesTableView.allowsMultipleSelection = true
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        freeTimeSlotCollectionView.allowsMultipleSelection = false
        
        readData()
        
        self.calendar.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)
        
    }
    
    func readData(){
        self.services.removeAll()
        self.servicesTableView.reloadData()
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
        
        self.selectedDate = date
        
        Funcs.busySlots(date: date, collection: freeTimeSlotCollectionView)
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let note = self.name.text
        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "OK", style: .default) { action in
            
            Funcs.addReservation(time: self.selectedTimeInMinutes, note: note, services: self.selectedServices, date: self.selectedDate)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTimeInMinutes = timeSlotInMinutes[indexPath.row]
        
        for cell in self.freeTimeSlotCollectionView.visibleCells{
            
            cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
        }
        
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)
        
        print(selectedTimeInMinutes)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Funcs.bookableSlotsInMinutes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! freeTimeBarberCollectionViewCell
        cell.label.text = Funcs.minutesToHour(Funcs.bookableSlotsInMinutes[indexPath.row])
        
        let iPath = self.freeTimeSlotCollectionView.indexPathsForSelectedItems!
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
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    func busySlots(date: Date) {
        let selectedDay = self.dateFormatter.string(from: date)
        var busySlots : [Int] = []
        
        print(selectedDay)
        print(String(Funcs.currentShop.ID))
        
        ref = Database.database().reference().child("prenotations").child(String(Funcs.currentShop.ID)).child(selectedDay)
        ref?.observe(.childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let time = userDict["time"] as? Int ?? 0
                busySlots.append(time)
                self.calcSlots(day: date, busySlots: busySlots)
                
                print(time)
                
            }})
        self.calcSlots(day: date, busySlots: busySlots)
        
    }
    
    func calcSlots(day: Date, busySlots: [Int]) {
        print(busySlots)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = DateFormatter.Style.full
        
        timeSlotInMinutes = []
        let selectedDay = formatter.string(from: day).components(separatedBy: ",")
        print(selectedDay[0])
        let slotsInADay = 1440 / slotSizeInMinutes
        
        for currslot in 0 ... slotsInADay {
            var isBookable = false
            
            let currentSlotMinute = currslot * slotSizeInMinutes
            if let arrayDay = (Funcs.currentShop.hours?[selectedDay[0]]){
                for shopOpeningFrame in arrayDay {
                    //TODO: bisogna aggiungere a currentSlotMinute la durata del servizio (dei servizi) selezionati
                    if (currentSlotMinute >= shopOpeningFrame[0] && currentSlotMinute < shopOpeningFrame[1] && !timeSlotInMinutes.contains(currentSlotMinute) && !busySlots.contains(currentSlotMinute)){
                        isBookable = true
                    }
                    if (isBookable){
                        timeSlotInMinutes.append(currentSlotMinute)
                        isBookable = false
                    }
                }
            }
            
        }
        freeTimeSlotCollectionView.reloadData()
    }
}

