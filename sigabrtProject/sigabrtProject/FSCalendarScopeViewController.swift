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


class FSCalendarScopeExampleViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource  {

    
    var prenotations : [(nameCustomer: String, service: [String : String], time: String)
        ] = []
    
    var timeSlot = ["9:00","9:15","9:30","9:45","10:00"]
    
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
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
        formatter.dateFormat = "dd-MM-yyyy"
        selectedDate = formatter.string(from: data)
        
        self.calendar.scope = .week
        calendar.appearance.headerDateFormat = "MMM yyyy"
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }

        cv.delegate = self
        cv.dataSource = self
        
        self.view.addGestureRecognizer(self.scopeGesture)
        
        readData()
    }
    
    func readData(){
    
    //FIRBASE REFERENCE
    var ref:DatabaseReference
    ref = Database.database().reference()
        
        ref.child("prenotations/\(selectedDate)/\(user!.uid)/").observeSingleEvent(of :.value, with: { (snapshot) in
        if ( snapshot.value is NSNull ) {
            print("not found")
        }
        else{
    let value = snapshot.value as? NSDictionary
    let name = value?["name"] as? String ?? ""
            let service = value?["service"] as! [String: String] ?? [:]
    let time = value?["time"] as? String ?? ""
    
    self.prenotations.append((nameCustomer: name, service: service, time: time))
    print(self.prenotations)
    self.cv.reloadData()
    print("cia")
        }
            }) { (error) in
                    print(error.localizedDescription)
            }
        
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        self.readData()
        self.selectedDate = self.dateFormatter.string(from: date)
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- UITableViewDataSource
    @IBAction func addPrenotation(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "addItem", sender: nil)
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeSlot.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!  CollectionViewCell
        cell.time.text =  timeSlot[indexPath.row]
        return cell
    }
    
    
    
}
