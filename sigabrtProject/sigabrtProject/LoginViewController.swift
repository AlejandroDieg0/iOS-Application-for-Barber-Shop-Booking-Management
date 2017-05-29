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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        error.alpha = 0
        loginError.alpha = 0
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
                
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case AuthErrorCode.userNotFound:
                        self.loginError.text = "User not found"
                        self.email.shake()
                    case AuthErrorCode.invalidEmail:
                        self.loginError.text = "Invalid Email"
                        self.email.shake()
                    case AuthErrorCode.wrongPassword:
                        self.loginError.text = "Wrong password"
                        self.passw.shake()
                    default:
                        self.loginError.text = error!.localizedDescription
                        print("Login User Error: \(error!.localizedDescription)")
                    }
                }
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
                print("Can't create an Account \n   withError: \(error!.localizedDescription) \n")
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case AuthErrorCode.invalidEmail:
                        self.error.text = "Invalid Email"
                        self.signUpMail.shake()
                    default:
                        self.error.text = error!.localizedDescription
                        self.signUpMail.shake()
                        self.signUpPassword.shake()
                    }
                }
                self.error.text = error!.localizedDescription
                UIView.animate(withDuration: 0.3, animations: {
                    self.error.alpha = 1
                })
                
                //let alert = ErrorMessageView.createAlert(title: "Can't create an Account!", message: "withError: \(error!.localizedDescription)")
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

