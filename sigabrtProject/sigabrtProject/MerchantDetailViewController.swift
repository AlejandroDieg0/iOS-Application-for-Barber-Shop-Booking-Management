//
//  BarberDetailViewController.swift
//  sigabrtProject
//
//  Created by Antonio Colella on 29/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit
import Firebase

class MerchantDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var tableViewController: UIView!
    @IBOutlet var editView: UIView!
    @IBOutlet weak var serviceName: UITextField!
    @IBOutlet weak var servicePrice: UITextField!
    @IBOutlet weak var serviceDuration: UITextField!

    @IBAction func cancelButton(_ sender: Any) {
        Funcs.animateOut(sender: self.editView)
    }
    
    @IBAction func updateButton(_ sender: Any) {
//        let ref = Database.database().reference().child("barbers/\(selectedShop.ID)/services/")
//        ref.updateChildValues([
//            "name": self.changeName.text!,
//            "phone": self.changePhone.text!,
//            "address": self.shopAddress.text!,
//            "description": self.shopDescription.text!
//            ])
//        
//        
//        self.changePhone.isUserInteractionEnabled = false
//        self.changePhone.textColor = UIColor.gray
//        self.changePhone.borderStyle = .none
//        
//        self.changeMail.isUserInteractionEnabled = false
//        self.changeMail.textColor = UIColor.gray
//        self.changeMail.borderStyle = .none
//        
//        self.changeName.isUserInteractionEnabled = false
//        self.changeName.textColor = UIColor.gray
//        self.changeName.borderStyle = .none
//        
//        self.shopDescription.isUserInteractionEnabled = true
//        self.shopDescription.textColor = UIColor.black
//        self.shopDescription.borderStyle = .none
//        
//        
//        self.shopAddress.isUserInteractionEnabled = true
//        self.shopAddress.textColor = UIColor.black
//        self.shopAddress.borderStyle = .none
    }
    var selectedShop: Shop!

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
            Funcs.animateIn(sender: self.editView)
        

            print("sono qui")
        }
        edit.backgroundColor = .red
        let cancel = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
        }
        cancel.backgroundColor = .blue
        return [edit,cancel]
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
