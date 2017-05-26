import UIKit
import FSCalendar
import Nuke
import Firebase

class UserReservationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    let slotSizeInMinutes = 15
    var selectedDate : Date = Date()

    var selectedShop: Shop!
    
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
        self.timeCollectionView.delegate = self
        self.timeCollectionView.dataSource = self
        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.servicesCollectionView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        let data = selectedDate

        Funcs.busySlots(date: data, collection: timeCollectionView)

        
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
        Funcs.busySlots(date: date, collection: timeCollectionView)
        
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
    
    
    
}
