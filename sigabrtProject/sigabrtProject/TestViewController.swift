//
//  TestViewController.swift
//  SIGABRT
//
//  Created by Fabio on 15/05/2017.
//  Copyright © 2017 Fabio Borgato. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TestViewController: UITableViewController {

    var x = ""
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
    @IBOutlet var reauthView: UIView!
    
    //INFO LABEL
    @IBOutlet weak var labelMail: UILabel!
    @IBOutlet weak var changemail: UITextField!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var helloName: UILabel!
    @IBOutlet weak var changePhone: UITextField!
    @IBOutlet weak var labelPhone: UILabel!
    
    
    // REAUTH
    @IBOutlet weak var reauthMail: UITextField!
    @IBOutlet weak var reauthPassword: UITextField!
    @IBOutlet weak var reauthError: UILabel!
    @IBOutlet weak var sendMailPwReset: UIButton!

    //CHANGE BUTTON
    @IBOutlet weak var nameChangeButton: UIButton!
    @IBOutlet weak var sendMailPwbutton: UIButton!
    @IBOutlet weak var mailUpdateButton: UIButton!
    @IBOutlet weak var phoneUpdateButton: UIButton!
   
    
    // ICON
    @IBOutlet weak var userNameIcon: UIImageView!
    @IBOutlet weak var mailIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var loveIcon: UIImageView!
 
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    //GESTURE
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TestViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)


    self.mailUpdateButton.alpha = 0
    self.phoneUpdateButton.alpha = 0
    self.nameChangeButton.alpha = 0
    self.changeName.alpha = 0
    self.changePhone.alpha = 0
    self.changemail.alpha = 0
    self.doneButton.alpha = 0
    self.reauthError.alpha = 0
   
    
        
        if(FBSDKAccessToken.current() != nil){
            
            self.editButton.alpha = 0
            self.doneButton.alpha = 0
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
                    let email = data["email"]
                    
                    
                    self.helloName.text = "Hello \( String(describing: firstName!))"
                    self.labelName.text = firstName! as? String
                    self.labelMail.text = email as? String
                    self.sendMailPwReset.setTitle("Connected as \(firstName!)", for: .normal)
                    
                }
            })

        }else{
            if Auth.auth().currentUser != nil {
                
                helloName.text = "Hello \(String(describing:  user!.displayName ))"
                self.labelName.text = user!.displayName
                self.labelMail.text = user!.email
                
            } else {
                print("no logged with Firebase")
                helloName.text = "Hello User!"
            }
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
        dismiss(animated: true, completion: nil)
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
        guard let mail = self.changemail.text, !mail.isEmpty else {
            return
        }
        animateIn(sender: reauthView)
        Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
            // ...
        }

        return
    }
    

    
    // update del nome
    
    @IBAction func changeName(_ sender: Any) {
        guard let newName = self.changeName.text, !newName.isEmpty else {
            self.changeName.shake()
            return
        }
        if newName.characters.count > 3{
            x = "name"
            animateIn(sender: reauthView)
        }
            
        else{
            self.changeName.shake()
        }

        return
    }
    
    // update della mail
    
    @IBAction func mailUpdate(_ sender: Any) {
        guard let newMail = self.changemail.text, !newMail.isEmpty else {
            self.changemail.shake()
            return
        }
        if newMail.characters.count > 3{
            x = "mailUpdate"
            animateIn(sender: reauthView)
        }
        else{
            self.changemail.shake()
        }
        return
    }

    // ANIMAZIONI
    
    func animateIn(sender: UIView) {
        //        let xPosition = view.center as CGFloat
        //        let yPosition = view.center.y - 20
        //
        //        let height = 330 as CGFloat
        //        let width = 260 as CGFloat
        //
        //        sender.frame = CGRect(x: xPosition,y: yPosition,width: width,height: height)
        sender.center = self.view.center
        self.view.addSubview(sender)
        
        sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        sender.alpha = 0
        UIView.animate(withDuration: 0.4) {
            sender.alpha = 0.9
            
            
            sender.transform = CGAffineTransform.identity
        }
        
    }
    
    
    func animateOut (sender: UIView) {
        UIView.animate(withDuration: 0.4, animations: {
            sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            sender.alpha = 0
            
        }) { (success:Bool) in
            sender.removeFromSuperview()
        }
    }
    @IBAction func reauthButton(_ sender: UIButton) {
      
        guard let email = self.reauthMail.text, !email.isEmpty else {
            self.reauthError.alpha = 1
            self.reauthError.text = "You have to reauth to change your info"
            self.reauthMail.shake()
            return
        }
        guard let password = self.reauthPassword.text, !password.isEmpty else {
            self.reauthError.alpha = 1
            self.reauthError.text = "You have to reauth to change your info"
            self.reauthPassword.shake()
            return
        }
        
        firebaseAuth.signIn(withEmail: email, password: password) { user, error in
            if error != nil {
                self.reauthError.text = "Wrong mail or password."
                UIView.animate(withDuration: 0.3, animations: {
                    self.reauthError.alpha = 1
                    
               })
                self.reauthMail.shake()
                self.reauthPassword.shake()
                print(error ?? "error")
                
            } else {
                // User re-authenticated.
                
                self.reauthMail.text = ""
                self.reauthPassword.text = ""
                self.reauthError.alpha = 0
                
                switch self.x {
                case "name":
                    
                    let newName = self.changeName.text
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = newName
                    changeRequest?.commitChanges() { (error) in
                        // ...
                    }
                    self.animateOut(sender: self.reauthView)
                    UIView.animate(withDuration: 0.4, animations: {
                        self.changeName.alpha = 0
                        self.changeName.text = ""
                        self.labelName.alpha = 1
                        self.nameChangeButton.alpha = 0
                        self.userNameIcon.alpha = 1
                        self.labelName.text = newName!
                        self.helloName.text = "Hello \(newName!)"
                    })
                
                case "mailUpdate":
                    let newMail = self.changemail.text
                    Auth.auth().currentUser?.updateEmail(to: newMail!) { (error) in

                    }
                    self.animateOut(sender: self.reauthView)
                    UIView.animate(withDuration: 0.4, animations: {
                        self.changemail.alpha = 0
                        self.changemail.text = ""
                        self.labelMail.alpha = 1
                        self.labelMail.text = newMail
        
                        
                    })
                    
                default:
                    return
                }
            }
        }
  
    }
    
    
    @IBAction func editInfo(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.labelMail.alpha = 0
            self.labelName.alpha = 0
            self.labelPhone.alpha = 0
            self.mailUpdateButton.alpha = 1
            self.phoneUpdateButton.alpha = 1
            self.nameChangeButton.alpha = 1
            self.changeName.alpha = 1
            self.changemail.alpha = 1
            self.userNameIcon.alpha = 0
            self.mailIcon.alpha = 0
            self.phoneIcon.alpha = 0
            self.editButton.alpha = 0
            self.doneButton.alpha = 1
            self.changePhone.alpha = 1
        }
    }

    @IBAction func doneButton(_ sender: Any) {
    UIView.animate(withDuration: 0.4) {
        self.labelMail.alpha = 1
        self.labelName.alpha = 1
        self.labelPhone.alpha = 1
        self.mailUpdateButton.alpha = 0
        self.phoneUpdateButton.alpha = 0
        self.nameChangeButton.alpha = 0
        self.changeName.alpha = 0
        self.changemail.alpha = 0
        self.userNameIcon.alpha = 1
        self.mailIcon.alpha = 1
        self.phoneIcon.alpha = 1
        self.editButton.alpha = 1
        self.doneButton.alpha = 0
        self.changePhone.alpha = 0
       }
    }
    @IBAction func cancelButton(_ sender: Any) {
        animateOut(sender: reauthView)
    }

}
