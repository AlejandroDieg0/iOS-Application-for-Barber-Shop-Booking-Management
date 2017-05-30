//
//  BarberDetailViewController.swift
//  sigabrtProject
//
//  Created by Antonio Colella on 29/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit
import Firebase

class BarberDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var tableViewController: UIView!
    
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
        performSegue(withIdentifier: "serviceDetails", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "serviceDetails"{
            let secondVC = segue.destination as! ServiceDetailViewController
            let selectedIndex = serviceTableView.indexPathForSelectedRow?.row
            secondVC.selectedService = selectedShop.services[selectedIndex!]
        }
    }
}
