
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
    var selectedDuration = 0
    
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
        print("qui")
        print(data)
        self.calendar.scope = .week
        calendar.appearance.headerDateFormat = "MMM yyyy"
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }

        Funcs.busySlots(shop: Funcs.currentShop, date: data, duration: selectedDuration, collection: freeTimeSlotCollectionView)
        
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
        print("did select date \(date)")
        self.selectedDate = date
        Funcs.busySlots(shop: Funcs.currentShop, date: date, duration: self.selectedDuration, collection: freeTimeSlotCollectionView)
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(calendar.currentPage))")
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let note = self.name.text
        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
        let errorAlert = UIAlertController(title: "Missing Informations", message: "Please check the details of your reservations", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "OK", style: .default) { action in
            
            Funcs.addReservation(time: self.selectedTimeInMinutes, note: note, services: self.selectedServices, date: self.selectedDate)
            self.selectedTimeInMinutes = 0
            self.selectedServices = []
            let selectedItems = self.servicesTableView.indexPathsForSelectedRows
            for indexPath in selectedItems! {
                self.servicesTableView.deselectRow(at: indexPath, animated:true)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        if (self.selectedTimeInMinutes == 0 ||  self.selectedServices.count == 0 ){
            self.present(errorAlert, animated: true, completion:  nil)

        }else{
            self.present(actionSheet, animated: true, completion:  nil)
        }
        
        
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
        self.selectedDuration = self.selectedDuration + services[indexPath.row].duration
        Funcs.busySlots(shop: Funcs.currentShop, date: self.selectedDate, duration: self.selectedDuration, collection: freeTimeSlotCollectionView)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedServices = self.selectedServices.filter { $0.name != services[indexPath.row].name }
        self.selectedDuration = self.selectedDuration - services[indexPath.row].duration
        Funcs.busySlots(shop: Funcs.currentShop, date: self.selectedDate, duration: self.selectedDuration, collection: freeTimeSlotCollectionView)
        return indexPath
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTimeInMinutes = Funcs.bookableSlotsInMinutes[indexPath.row]
        
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
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        return formatter
    }()
}

