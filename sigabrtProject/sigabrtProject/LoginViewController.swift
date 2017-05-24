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


class LoginViewController: UIViewController {
    
    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet var loginView: UIView!
    @IBOutlet var signupView: UIView!
    @IBOutlet var confirmPrenotation: UIView!
    
    @IBOutlet weak var passw: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var signUpMail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var loginError: UILabel!
    
    
    @IBOutlet weak var fbBut: UIButton!
    
    //var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        logIn.backgroundColor = UIColor.clear
        logIn.layer.borderWidth = 1.3
        logIn.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
        signUp.backgroundColor = UIColor.clear
        signUp.layer.borderWidth = 1.3
        signUp.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
        
        //}
        
        error.alpha = 0
        loginError.alpha = 0
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        //Auth.auth().removeStateDidChangeListener(handle!)
        // [END remove_auth_listener]
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let email = self.email.text , !email.isEmpty else {
            //print("\n [Error] Write Username \n")
            self.email.shake()
            self.loginError.text = "Username empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.loginError.alpha = 1
            })
            
            return
        }
        
        guard let password = self.passw.text, !password.isEmpty else {
            //print("\n [Error] Write Password \n")
            self.passw.shake()
            self.loginError.text = "Password empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.loginError.alpha = 1
            })
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard error == nil else {
                // print(" \n [ERROR] Can't Sign In \n   withError: \( error!.localizedDescription) \n")
                // let alert = ErrorMessageView.createAlert(title: "Can't Sign In!", message: "(error!.localizedDescription)")
                //   self.show(alert, sender: nil)
                self.passw.shake()
                self.email.shake()
                self.loginError.text = "No user found."
                UIView.animate(withDuration: 0.3, animations: {
                    self.loginError.alpha = 1
                })
                return
            }
            let x = user!.displayName ?? "ciao"
            print("\n Welcome \(user!.email! + "\n" + x + "\n" + user!.uid)")
            self.email.text = ""
            self.passw.text = ""
            
            Funcs.animateOut(sender: self.loginView)
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
        })
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        guard let signUpMail = self.signUpMail.text , !signUpMail.isEmpty else {
            //print("\n [Error] Write Username \n")
            self.signUpMail.shake()
            self.error.text = "Email empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.error.alpha = 1
            })
            return
        }
        
        guard let signUpPassword = self.signUpPassword.text, !signUpPassword.isEmpty else {
            //print("\n [Error] Write Password \n")
            self.signUpPassword.shake()
            self.error.text = "Password empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.error.alpha = 1
            })
            return
        }
        
        Auth.auth().createUser(withEmail: signUpMail, password: signUpPassword, completion: { (user, error) in
            
            guard error == nil else {
                // print(" \n [ERROR] Can't create an Account \n   withError: \(error!.localizedDescription) \n")
                
                self.signUpMail.shake()
                self.signUpPassword.shake()
                self.error.text = error!.localizedDescription
                UIView.animate(withDuration: 0.3, animations: {
                    self.error.alpha = 1
                })
                
                // let alert = ErrorMessageView.createAlert(title: "Can't create an Account!", message: "withError: \(error!.localizedDescription)")
                //self.show(alert, sender: nil)
                
                return
            }
            
            print("Welcome \(user!.email!)")
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                // handle error
            })
            
            Funcs.animateOut(sender: self.signupView)
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
            
        })
        
    }
    
    @IBAction func newAccount(_ sender: UIButton) {
        Funcs.animateOut(sender: loginView)
        Funcs.animateIn(sender: signupView)
    }
    
    @IBAction func alreadyHaveAccount(_ sender: UIButton) {
        Funcs.animateOut(sender: signupView)
        Funcs.animateIn(sender: loginView)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        Funcs.animateOut(sender: loginView)
    }
    @IBAction func prenota(_ sender: Any) {
        switch Auth.auth().currentUser {
            
        case nil:
            print(" \n Current User is logged out \n  show LoginViewController \n")
            Funcs.animateIn(sender: loginView)
        default:
            
            Funcs.animateIn(sender: confirmPrenotation)
        }
    }
    
    @IBAction func buttone(_ sender: Any) {
        Funcs.animateOut(sender: confirmPrenotation)
        
        /*UIView.animate(withDuration: 0.4) {
         self.visualEffect.alpha = 0
         }*/
    }
    
    @IBAction func fbLogin(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success:
                print("Logged in!")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if error != nil {
                        // ...
                        return
                    }
                    
                    Funcs.animateOut(sender: self.loginView)
                    self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                    
                }
            }
        }
    }
}

