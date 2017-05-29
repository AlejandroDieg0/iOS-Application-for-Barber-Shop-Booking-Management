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
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let tableViewInfo = tableViewController.parentViewController as! barberProfileViewController
        
        if isEditing {
            print(editing)
            tableViewInfo.changePhone.isUserInteractionEnabled = true
            tableViewInfo.changePhone.textColor = UIColor.black
            
            tableViewInfo.changeMail.isUserInteractionEnabled = true
            tableViewInfo.changeMail.textColor = UIColor.black
            
            tableViewInfo.changeName.isUserInteractionEnabled = true
            tableViewInfo.changeName.textColor = UIColor.black
            
            
        } else {
            let ref = Database.database().reference().child("user/\(Auth.auth().currentUser?.uid ?? "noLogin")")
            ref.updateChildValues([
                "name": tableViewInfo.changeName.text!,
                "phone": tableViewInfo.changePhone.text!,
                ])
            
            tableViewInfo.changePhone.isUserInteractionEnabled = false
            tableViewInfo.changePhone.textColor = UIColor.gray
            
            tableViewInfo.changeMail.isUserInteractionEnabled = false
            tableViewInfo.changeMail.textColor = UIColor.gray
            
            tableViewInfo.changeName.isUserInteractionEnabled = false
            tableViewInfo.changeName.textColor = UIColor.gray
            
            print("Changes Uploaded")
            
        }
    }
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedShop.services.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serviceTableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! barberSelfServiceTableViewCell
        cell.labelService.text = selectedShop.services[indexPath.row].name
        cell.labelPrice.text = String(selectedShop.services[indexPath.row].price) + " €"
        cell.labelDuration.text = String(selectedShop.services[indexPath.row].duration) + " Min"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
