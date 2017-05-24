//
//  TestViewController.swift
//  SIGABRTUserProfileViewController
//
//  Created by Fabio on 15/05/2017.
//  Copyright © 2017 Fabio Borgato. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class barberProfileViewController: UITableViewController {
    
    var x = ""
    var id :String = "1"
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
     var services : [Service] = []
    
    //INFO LABEL
    @IBOutlet weak var changeMail: UITextField!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var helloName: UILabel!
    @IBOutlet weak var changePhone: UITextField!
    @IBOutlet weak var logoBarber: UIImageView!
    
    @IBOutlet weak var tb: UITableView!
    
    @IBOutlet weak var sendMailPwReset: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tb.delegate = self
        tb.dataSource = self
        logoBarber.layer.cornerRadius = logoBarber.frame.size.width/2
        // let editBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: Selector(("setEditing")))
        navigationItem.rightBarButtonItem = editButtonItem
        
        //GESTURE
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.changeName.isUserInteractionEnabled = false
        self.changeMail.isUserInteractionEnabled = false
        self.changePhone.isUserInteractionEnabled = false
        
        
        if(FBSDKAccessToken.current() != nil){
            
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,email, picture.type(large)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(String(describing: error))")
                }
                else
                {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    print(data)
                    let firstName = data["first_name"]
                    
                    self.helloName.text = "Hello \(firstName!)"
                    self.changeName.text = firstName! as? String
                    self.changeMail.text = data["email"] as? String
                    self.sendMailPwReset.setTitle("Connected as \(firstName!)", for: .normal)
                    
                }
            })
            
        }else{
            if Auth.auth().currentUser != nil {
                
                loadUserData()
                
            } else {
                print("no logged with Firebase")
                helloName.text = "Hello User!"
            }
        }
        
        
    }
    
    func loadUserData(){
        let user = Auth.auth().currentUser
        let ref = Database.database().reference()
        ref.child("user").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                self.changePhone.text = value["phone"] as? String ?? ""
                self.changeName.text = value["name"] as? String ?? ""
                self.changeMail.text = user?.email
                self.helloName.text = "Hello \(self.changeName.text!)"
            } else {
                self.inizializeUserData()
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    func loadBarberService(){
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
    func inizializeUserData(){
        let user = Auth.auth().currentUser
        if (user != nil){
            let ref: DatabaseReference = Database.database().reference()
            let post = [
                "name":  "",
                "phone": "",
                "favbarber":   -1,
                ] as [String : Any]
            
            ref.child("user/\(user!.uid)/").setValue(post)
            print("New User Data inizialidez")
        }
        
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // logout
    
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.navigationController?.popViewController(animated: true)
        return
    }
    
    // Delete profile
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        user?.delete { error in
            if error != nil {
                // An error happened.
            } else {
                // Account deleted.
                self.dismiss(animated: true, completion: nil)
            }
        }
        return
    }
    
    // Send mail for password reset
    
    @IBAction func sendMailPwReset(_ sender: Any) {
        guard let mail = self.changeMail.text, !mail.isEmpty else {
            return
        }
            Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
            // ...
        }
        
        return
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            print(editing)
            self.changePhone.isUserInteractionEnabled = true
            self.changePhone.textColor = UIColor.black
            
            self.changeMail.isUserInteractionEnabled = true
            self.changeMail.textColor = UIColor.black
            
            self.changeName.isUserInteractionEnabled = true
            self.changeName.textColor = UIColor.black
            
            
        } else {
            createAlert()
            let ref = Database.database().reference().child("user/\(Auth.auth().currentUser?.uid ?? "noLogin")")
            ref.updateChildValues([
                "name": self.changeName.text!,
                "phone": self.changePhone.text!,
                ])
            
            self.changePhone.isUserInteractionEnabled = false
            self.changePhone.textColor = UIColor.gray
            
            self.changeMail.isUserInteractionEnabled = false
            self.changeMail.textColor = UIColor.gray
            
            self.changeName.isUserInteractionEnabled = false
            self.changeName.textColor = UIColor.gray
            
            print("Changes Uploaded")
            
        }
    }
    
    //TABLE VIEW
     override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tb{
        return 1
        }
        else{
            return super.numberOfSections(in: tableView)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if tableView == self.tb{
        return services.count
       } else {
        return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       if tableView == self.tb{
        let cell = tb.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! barberSelfServiceTableViewCell
        cell.servizio.text = services[indexPath.row].name
        cell.price.text = String(services[indexPath.row].price) + "€"
        return cell
       }
       else{
        return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    // REAUTH
    func createAlert(){
        let alert = UIAlertController(title: "Authentication", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (email) in
            email.placeholder = "Current Email"
        }
        alert.addTextField { (password) in
            password.placeholder = "Current Password"
            password.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
            let textF = alert.textFields?[0] as UITextField!
            print(textF)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
         self.present(alert, animated: true)
    }
    
    
}
