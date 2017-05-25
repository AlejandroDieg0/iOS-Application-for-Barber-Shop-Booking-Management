//
//  FSCalendarScopeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import SystemConfiguration


class BarberPagePrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource {

    
    var prenotationList = [Prenotation]()
    
    var ref: DatabaseReference? = nil
   
    var timeSlot = ["9:00","9:15","9:30","9:45","10:00"]
    @IBOutlet weak var updated: UILabel!
    
    @IBOutlet weak var totalReservations: UILabel!
    
    @IBOutlet weak var freeTimeCollectionView: UICollectionView!
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

        freeTimeCollectionView.delegate = self
        freeTimeCollectionView.dataSource = self
        prenotationCollectionView.delegate = self
        prenotationCollectionView.dataSource = self
        
        self.view.addGestureRecognizer(self.scopeGesture)
        
        readData()
    }
    
    func readData(){
    prenotationList.removeAll()
    self.prenotationCollectionView.reloadData()
    //FIRBASE REFERENCE
    ref = Database.database().reference().child("prenotations/\(Funcs.currentShop.ID)").child(selectedDate)
    ref?.observe(.childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let name = userDict["name"] as? String ?? ""
                let time = userDict["time"] as? Int ?? 0
                
                let service = userDict["services"] as? [String: Any]
                let serviceArray = service?["name"] as? String ?? ""
                let price = service?["price"] as? Int ?? 0
                
                let  x = Prenotation(customerName: name, tipoServizio: serviceArray, prezzoServizio: price, timeInMinute: time)
                self.prenotationList.append(x)
            
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
           
        }
            
        else {
            return timeSlot.count
        }
       
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.prenotationCollectionView {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!  CollectionViewCell
        let total = String(prenotationList[indexPath.row].prezzoServizio) + "€"
        
        cell.name.text = prenotationList[indexPath.row].customerName
        cell.time.text = "\(prenotationList[indexPath.row].timeInMinute/60):\(prenotationList[indexPath.row].timeInMinute%60)"
        cell.total.text = total
        cell.services.text = prenotationList[indexPath.row].tipoServizio
        
        return cell
        }
        
        else{
        let cell = freeTimeCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! freeTimeBarberCollectionViewCell
        cell.label.text = timeSlot[indexPath.row]

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
