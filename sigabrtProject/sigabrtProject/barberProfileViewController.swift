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
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
    //INFO LABEL
    @IBOutlet weak var changeMail: UITextField!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var helloName: UILabel!
    @IBOutlet weak var changePhone: UITextField!
    
    
    // REAUTH
    @IBOutlet weak var reauthMail: UITextField!
    @IBOutlet weak var reauthPassword: UITextField!
    @IBOutlet weak var reauthError: UILabel!
    @IBOutlet weak var sendMailPwReset: UIButton!
    
    //CHANGE BUTTON
    @IBOutlet weak var sendMailPwbutton: UIButton!
    
    
    // ICON
    @IBOutlet weak var userNameIcon: UIImageView!
    @IBOutlet weak var mailIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func dismissKeyboard() {
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
