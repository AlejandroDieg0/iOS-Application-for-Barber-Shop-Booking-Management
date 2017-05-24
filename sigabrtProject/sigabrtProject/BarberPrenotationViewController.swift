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

class BarberPrenotationViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate,UITableViewDelegate, UITableViewDataSource , UIPickerViewDelegate, UIPickerViewDataSource{
  
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var time: UIPickerView!
    @IBOutlet weak var tb: UITableView!
    
    @IBOutlet weak var name: UITextField!
   
    var ref: DatabaseReference!
    var id :String = "1"
    
    var selectedDate = ""
    var selectedTime = ""
    var services : [Service] = []
    var selectedServices : [Service] = []

    var selectedTipo: [String] = []
    var selectedPrezzo : [Int] = []
    var timeSlot = ["09:00","09:15","09:30","09:45","10:00"]
    
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        time.delegate = self
        time.dataSource = self
        //today date
        let data = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        selectedDate = formatter.string(from: data)
        selectedTime = timeSlot.first!
        
       // self.time.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        tb.allowsMultipleSelection = true
        tb.delegate = self
        tb.dataSource = self
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        readData()

        self.calendar.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendar.scope = .week
        
        
       
    }
    
    func readData(){
        //service.removeAll()
        self.tb.reloadData()
        //FIRBASE REFERENCE
        var ref: DatabaseReference!
        ref = Database.database().reference().child("barbers/\(self.id)/services")
       
        ref?.observe(.childAdded, with: { snapshot in
            if !snapshot.exists() {
                print("null")
            }
            
            if let snapshotValue = snapshot.value as? [String:Any] {
                let tipo = (snapshotValue["name"])! as! String
                let price = (snapshotValue["price"])! as! Int
                let duration = (snapshotValue["duration"])! as! Int

                self.services.append(Service(name: tipo, duration: duration, price: price))
                self.tb.reloadData()
            }})
        
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
        
        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "OK", style: .default) { action in
        let customerName = self.name.text
            //FIRBASE REFERENCE
            let ref: DatabaseReference = Database.database().reference()
            
            let post = [
                "user":  self.user!.uid,
                "services": [
                    "price": 11, //self.selectedServices.price,
                    "type": "test", //self.selectedServices.name,
                    "duration": 20, //self.selectedServices.duration,

                ] ,
                "time":   self.selectedTime,
                "note": customerName ?? "Not inserted"
                ] as [String : Any]
            
            let key = ref.child("prenotations/1/\(self.selectedDate)/").childByAutoId().key
            
            ref.child("prenotations/1/\(self.selectedDate)/").child(key).setValue(post)
            
            //ref.child("prenotations/1/\(self.selectedDate)/").childByAutoId().setValue(post)
            print(key)
        })
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion:  nil)
//        //FIRBASE REFERENCE
    }
   
    //TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tb.dequeueReusableCell(withIdentifier: "cella", for: indexPath) as! addModifyCollectionViewCell
        cell.servizio.text = services[indexPath.row].name
        cell.price.text = String(services[indexPath.row].price) + "€"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectedServices.duration =  self.selectedServices.duration + services[indexPath.row].duration
//        self.selectedServices.price =  self.selectedServices.price + services[indexPath.row].price
//        
//        if (self.selectedServices.name == "" ){
//            self.selectedServices.name =  self.selectedServices.name + services[indexPath.row].name
//        } else{
//            self.selectedServices.name =  self.selectedServices.name + ", " + services[indexPath.row].name
//        }
//        
    }
    
    // PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeSlot.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeSlot[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTime = timeSlot[row]
        print(selectedTime)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

