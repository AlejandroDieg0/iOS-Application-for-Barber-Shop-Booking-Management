//
//  BarberDetailViewController.swift
//  sigabrtProject
//
//  Created by Antonio Colevar on 29/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit
import Firebase

class MerchantDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var tableViewController: UIView!
    @IBOutlet var editView: UIView!
    
    @IBOutlet var addView: UIView!
    
    @IBOutlet weak var serviceName: UITextField!
    @IBOutlet weak var servicePrice: UITextField!
    @IBOutlet weak var serviceDuration: UITextField!

    @IBOutlet weak var newServiceName: UITextField!
    @IBOutlet weak var newServiceDuration: UITextField!
    @IBOutlet weak var newServicePrice: UITextField!
    
    @IBOutlet weak var editableServiceTableView: UITableView!
    
    var selectedShop: Shop!
    var selectedID: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        self.serviceEditBt()
        serviceTableView.dataSource = self
        serviceTableView.delegate = self

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // let tableViewInfo = tableViewController.parentViewController  as! barberProfileViewController
        
        if isEditing {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editTableView"), object: self)

            
            
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "doneTableView"), object: self)

            
        }
    }
    func serviceEditBt()  {

    }
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedShop.services.count
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serviceTableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! barberSelfServiceTableViewCell
        cell.labelService.text = selectedShop.services[indexPath.row].name
        cell.labelPrice.text = String(selectedShop.services[indexPath.row].price) + " €"
        cell.labelDuration.text = String(selectedShop.services[indexPath.row].duration) + " Min"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // performSegue(withIdentifier: "serviceDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.serviceName.text = self.selectedShop.services[indexPath.row].name
            self.serviceDuration.text = String(self.selectedShop.services[indexPath.row].duration)
            self.servicePrice.text = String(self.selectedShop.services[indexPath.row].price)
            self.selectedID = indexPath.row
            Funcs.animateIn(sender: self.editView)
        

            print("sono qui")
        }
        edit.backgroundColor = .blue
        let cancel = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.selectedID = indexPath.row
            self.removeService()
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            
        }
        cancel.backgroundColor = .red
        return [edit,cancel]
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func removeService(){
        let ref = Database.database().reference()
        ref.child("barbers/\(selectedShop.ID)/services/\(self.selectedShop.services[selectedID!].id)").removeValue()
        self.selectedShop.services.remove(at: selectedID!)
        
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        Funcs.animateOut(sender: self.editView)
    }
    
    @IBAction func addServiceBtn(_ sender: Any) {
        Funcs.animateIn(sender: self.addView)
    }
    @IBAction func updateButton(_ sender: Any) {
        let ref = Database.database().reference().child("barbers/\(selectedShop.ID)/services/\(self.selectedShop.services[selectedID!].id)")
        ref.updateChildValues([
            "duration": Int(self.serviceDuration.text!) ?? 0,
            "name": self.serviceName.text!,
            "price": Int(self.servicePrice.text!) ?? 0
            ])
        self.selectedShop.services[selectedID!].name = self.serviceName.text!
        self.selectedShop.services[selectedID!].price =  Int(self.servicePrice.text!) ?? 0
        self.selectedShop.services[selectedID!].duration = Int(self.serviceDuration.text!) ?? 0
        
        self.editableServiceTableView.reloadData()
        Funcs.animateOut(sender: self.editView)
        
        
    }
    @IBAction func newServiceCancel(_ sender: Any) {
        Funcs.animateOut(sender: self.addView)

    }

    @IBAction func newServiceAdd(_ sender: Any) {
        let ref = Database.database().reference()
        let key = ref.child("barbers/\(selectedShop.ID)/services/").childByAutoId().key
        
        let post = [
            "price":  Int(self.newServicePrice.text!) ?? 0,
            "name": self.newServiceName.text ?? "missinName",
            "duration": Int(self.newServiceDuration.text!) ?? 0
            ] as [String : Any]
        ref.child("barbers/\(selectedShop.ID)/services/\(key)").setValue(post)
        print(key)
        self.selectedShop.services.append(Service(name: self.newServiceName.text!, duration: Int(self.newServiceDuration.text!) ?? 0, price: Int(self.newServicePrice.text!) ?? 0, id: key))
        
        self.editableServiceTableView.reloadData()
        Funcs.animateOut(sender: self.addView)
    }
}
