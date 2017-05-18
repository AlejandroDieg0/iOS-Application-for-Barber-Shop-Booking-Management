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
import TextFieldEffects
import UITextField_Shake


class loginViewController: UIViewController {
    
    let firebaseAuth = FIRAuth.auth()
    let user = FIRAuth.auth()?.currentUser
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
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
    
    var handle: FIRAuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
        visualEffect.alpha = 0
       
        logIn.backgroundColor = UIColor.clear
        logIn.layer.borderWidth = 1.3
        logIn.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
        signUp.backgroundColor = UIColor.clear
        signUp.layer.borderWidth = 1.3
        signUp.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            // ...
            }
      
        error.alpha = 0
        loginError.alpha = 0
        

        }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
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
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
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

    FIRAuth.auth()?.createUser(withEmail: signUpMail, password: signUpPassword, completion: { (user, error) in
        
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
        
        print("\n Welcome \(user!.email!)")
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
            // handle error
        })
        self.performSegue(withIdentifier: "loginSuccess", sender: nil)

    })
        
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
            sender.alpha = 0.85
            self.visualEffect.alpha = 0.5
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

   
    @IBAction func newAccount(_ sender: UIButton) {
        animateOut(sender: loginView)
        animateIn(sender: signupView)
        self.visualEffect.alpha = 0.5
    
    }
    
    @IBAction func alreadyHaveAccount(_ sender: UIButton) {
        animateIn(sender: loginView)
        animateOut(sender: signupView)
        
       
    }
    
    @IBAction func prenota(_ sender: Any) {
        switch FIRAuth.auth()?.currentUser {
            
        case nil:
            print(" \n Current User is logged out \n  show LoginViewController \n")
            animateIn(sender: loginView)
        default:
           
            animateIn(sender: confirmPrenotation)
        }
    }
    
    @IBAction func buttone(_ sender: Any) {
        animateOut(sender: confirmPrenotation)
        
        UIView.animate(withDuration: 0.4) { 
            self.visualEffect.alpha = 0
        }
    }
    
    @IBAction func fbLogin(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    // ...
                    if error != nil {
                        // ...
                        return
                    }
                    
                }
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
            }
        }
    }

    
}

