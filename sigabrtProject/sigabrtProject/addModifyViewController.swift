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

class addModifyViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate {
  
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var time: UIDatePicker!
    
    var selectedDate = ""
    var selectedTime = ""

    
    var service: [(tipo: String, prezzo: String)] = [("taglio", "10"),( "colore", "40") ,( "beard", "5")]
    var tipo: [String] = []
    var prezzo : [String] = []
    var timeSlot = ["09:00","09:15","09:30","09:45","10:00"]
    
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //today date
        let data = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        selectedDate = formatter.string(from: data)
        selectedTime = timeSlot.first!
        
        self.time.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        cv.allowsMultipleSelection = true
        cv.delegate = self
        cv.dataSource = self
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        self.calendar.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendar.scope = .week
       
    }
    
    func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        var convertedDate: String!
        dateFormatter.dateFormat = "hh:mm"
        convertedDate = dateFormatter.string(from: time.date)
        print(convertedDate)
        selectedTime = convertedDate

    }
    
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
         self.selectedDate = self.dateFormatter.string(from: date)
        print(selectedDate)
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        let selectedServiceTipe = tipo.joined(separator: ",")
        let selectedServicePrice = prezzo.joined(separator: ",")
        let customerName = name.text
        
        //FIRBASE REFERENCE
        let ref: DatabaseReference = Database.database().reference()
        let post = [
            "name":  customerName ?? "user",
            "services": [
                "prezzo": selectedServicePrice,
                "tipo": selectedServiceTipe
            ] ,
            "time":   selectedTime,
         ] as [String : Any]
        ref.child("prenotations/\(selectedDate)/\(String(describing: user!.uid))/").childByAutoId().setValue(post)
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return service.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cella", for: indexPath) as!  addModifyCollectionViewCell
        cell.servizio.text = service[indexPath.row].tipo
        cell.price.text = service[indexPath.row].prezzo
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tipo.append(service[indexPath.row].tipo)
        prezzo.append(service[indexPath.row].prezzo)

    
    }
    

}

