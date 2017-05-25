
import UIKit
import FSCalendar
import Firebase

class BarberPrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
  
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var servicesTableView: UITableView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var freeTimeSlotCollectionView: UICollectionView!
    
    var selectedDate = ""
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

        Funcs.busySlots(date: data, collection: freeTimeSlotCollectionView)
        
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
        self.selectedDate = self.dateFormatter.string(from: date)
        
        Funcs.busySlots(date: date, collection: freeTimeSlotCollectionView)
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "OK", style: .default) { action in
            let customerName = self.name.text
            //FIRBASE REFERENCE
            let ref: DatabaseReference = Database.database().reference()
            
            let post = [
                "user":  Auth.auth().currentUser!.uid,
                "time":  self.selectedTimeInMinutes,
                "note": customerName ?? "Not inserted"
                ] as [String : Any]
            
            let key = ref.child("prenotations/\(Funcs.currentShop.ID)/\(self.selectedDate)/").childByAutoId().key
            
            ref.child("prenotations/\(Funcs.currentShop.ID)/\(self.selectedDate)/").child(key).setValue(post)
            
            for service in self.selectedServices {
                let post = ["price": service.price,
                            "type": service.name,
                            "duration": service.duration] as [String : Any]
                ref.child("prenotations/\(Funcs.currentShop.ID)/\(self.selectedDate)/\(key)/services").childByAutoId().setValue(post)
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
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        return formatter
    }()
}

