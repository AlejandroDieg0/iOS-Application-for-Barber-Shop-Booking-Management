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


class BarberPagePrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource  {

    
//    var prenotations : [(customerName: String, tipoServizio: String,prezzoServizio : [String], timeSelected: String, total: Int)] = []
    var prenotationList = [prenotation]()
   
    var timeSlot = ["9:00","9:15","9:30","9:45","10:00"]

    
//    var customerName = [String]()
//    var tipoServizio: [String] = []
//    var prezzoServizio : [String] = []
//    var timeSelected = String()
    
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
    prenotationList.removeAll()
    //FIRBASE REFERENCE
    let ref = Database.database().reference().child("prenotations").child(selectedDate).child(user!.uid)
      
    ref.observe(.childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let name = userDict["name"] as? String ?? ""
                let time = userDict["time"] as? String ?? ""
                
                let service = userDict["services"] as? [String: Any]
                let serviceArray = service?["tipo"] as! String
                let priceArray = service?["prezzo"] as! String
            
//                let splittedTipe = serviceArray.characters.split { [",", "[","]"].contains(String($0)) }
//                let trimmedTipe = splittedTipe.map { String($0).trimmingCharacters(in: .whitespaces) }

                let splittedPrice = priceArray.characters.split { [",", "[","]"].contains(String($0)) }
                let trimmedPrice = splittedPrice.map { String($0).trimmingCharacters(in: .whitespaces) }
            
                var totalPrice = 0
                let intArray = trimmedPrice.map { Int($0)!}
                for i in 0..<intArray.count {
                    totalPrice += intArray[i]
                }

              // con classe
                let  x = prenotation(customerName: name, tipoServizio: serviceArray, prezzoServizio: trimmedPrice, timeSelected: time, total: totalPrice)
                self.prenotationList.append(x)

                
            // con array
//                self.prenotations.append((customerName: name, tipoServizio: serviceArray,prezzoServizio: trimmedPrice, timeSelected: time, total: totalPrice))
//                print(self.prenotations)
               
                self.cv.reloadData()
            }})
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
        return prenotationList.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!  CollectionViewCell
        
//        let total = String(prenotations[indexPath.row].total)
//        cell.time.text = prenotations[indexPath.row].timeSelected
//        cell.name.text = prenotations[indexPath.row].customerName
//        cell.total.text = total
//        cell.services.text = prenotations[indexPath.row].tipoServizio

        let total = String(prenotationList[indexPath.row].total)
        cell.name.text = prenotationList[indexPath.row].customerName
        cell.time.text = prenotationList[indexPath.row].timeSelected
        cell.total.text = total
        cell.services.text = prenotationList[indexPath.row].tipoServizio
        
        
        return cell
    }
    
    
    
}
