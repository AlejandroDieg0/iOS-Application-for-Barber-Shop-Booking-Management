//
//  loginViewController.swift
//  SIGABRT
//
//  Created by Fabio on 15/05/2017.
//  Copyright © 2017 Fabio Borgato. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import UITextField_Shake


class barberLoginViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var logIn: UIButton!
    
    @IBOutlet weak var passw: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var error: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            // ...
        }
        
        error.alpha = 0
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        Auth.auth().removeStateDidChangeListener(handle!)
        // [END remove_auth_listener]
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let email = self.email.text , !email.isEmpty else {
            //print("\n [Error] Write Username \n")
            self.email.shake()
            self.error.text = "Username empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.error.alpha = 1
            })
            
            return
        }
        
        guard let password = self.passw.text, !password.isEmpty else {
            //print("\n [Error] Write Password \n")
            self.passw.shake()
            self.error.text = "Password empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.error.alpha = 1
            })
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard error == nil else {
                                self.passw.shake()
                self.email.shake()
                self.error.text = "No user found."
                UIView.animate(withDuration: 0.3, animations: {
                    self.error.alpha = 1
                })
                return
            }
            let x = user!.displayName ?? "ciao"
            print("\n Welcome \(user!.email! + "\n" + x + "\n" + user!.uid)")
            self.email.text = ""
            self.passw.text = ""
            

            self.performSegue(withIdentifier: "barberLoginSuccess", sender: nil)
            
        })
        
    }
    

}

