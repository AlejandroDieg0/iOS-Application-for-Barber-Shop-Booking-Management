import UIKit
import FSCalendar
import Nuke
import Firebase

class UserReservationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var barbershopName: UILabel!
    @IBOutlet weak var barbershopPhone: UILabel!
    @IBOutlet weak var barbershopAddress: UILabel!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    let slotSizeInMinutes = 15
    var selectedDate : Date = Date()
    var selectedTimeInMinutes = 0
    var selectedShop: Shop!
    var selectedServices : [Service] = []
    var selectedDuration = 0
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
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
        print(selectedShop.desc)
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        timeCollectionView.allowsMultipleSelection = false
        servicesCollectionView.allowsMultipleSelection = true

        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.servicesCollectionView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        let data = selectedDate
        
        barbershopName.text = selectedShop.name
        barbershopPhone.text = selectedShop.phone
        barbershopAddress.text = selectedShop.address
        
        Funcs.busySlots(shop: Funcs.currentShop, date: data, duration: selectedDuration, collection: timeCollectionView)
        
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.servicesCollectionView.contentOffset.y <= -self.servicesCollectionView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        Funcs.busySlots(shop: Funcs.currentShop, date: date, duration: self.selectedDuration, collection: timeCollectionView)
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.servicesCollectionView) {
            return selectedShop.services.count
        } else {
            return Funcs.bookableSlotsInMinutes.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.servicesCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defCell", for: indexPath) as!  ServiceCollectionViewCell
            
            cell.labelServiceName.text = selectedShop.services[indexPath.row].name
            cell.labelServicePrice.text = "\(selectedShop.services[indexPath.row].price) €"
            
            let imageURL = Storage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("services/\(selectedShop.services[indexPath.row].name).png")
            
            imageURL.downloadURL(completion: { (url, error) in
                
                print(imageURL)
                if url != nil {Nuke.loadImage(with: url!, into: cell.imageViewService)}
                
                
            })
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "freeTimeCell", for: indexPath) as! freeTimeBarberCollectionViewCell
            cell.label.text = Funcs.minutesToHour(Funcs.bookableSlotsInMinutes[indexPath.row])
            
            let iPath = self.timeCollectionView.indexPathsForSelectedItems!
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
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (collectionView == self.servicesCollectionView) {
                self.selectedServices = self.selectedServices.filter { $0.name != selectedShop.services[indexPath.row].name }
            
                collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.servicesCollectionView) {
            
            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            self.selectedServices.append(selectedShop.services[indexPath.row])
            
        }else{
            selectedTimeInMinutes = Funcs.bookableSlotsInMinutes[indexPath.row]
            
            for cell in self.timeCollectionView.visibleCells{
                cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            }
            
            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)
            
            print(selectedTimeInMinutes)
            }

        }
    
    @IBAction func saveReservation(_ sender: Any) {

        if(Auth.auth().currentUser == nil){
            let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as? LoginViewController
            self.addChildViewController(controller!)
            Funcs.animateIn(sender: (controller?.loginView)!)
        } else {
        
        //TODO: Vogliamo dare la possibilità al utente di inserire delle note durante la prenotazione ??
        let note = "NoNote"
        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
        let errorAlert = UIAlertController(title: "Missing Informations", message: "Please check the details of your reservations", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "OK", style: .default) { action in
            
            Funcs.addReservation(time: self.selectedTimeInMinutes, note: note, services: self.selectedServices, date: self.selectedDate)
            self.selectedTimeInMinutes = 0
            self.selectedServices = []
            let selectedItems = self.servicesCollectionView.indexPathsForSelectedItems
            for indexPath in selectedItems! {
                self.servicesCollectionView.deselectItem(at: indexPath, animated:true)
                if self.servicesCollectionView.cellForItem(at: indexPath) != nil {
                    self.servicesCollectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                }
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
    }
    
}
