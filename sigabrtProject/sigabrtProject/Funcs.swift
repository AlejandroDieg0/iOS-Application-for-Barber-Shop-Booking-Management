//
//  Funcs.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 19/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class Funcs: NSObject {
    static var loggedUser : User!
    static var currentShop : Shop!
    static var flagFavBarber:Int = 0
    
    static func animateIn(sender: UIView) {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = topController.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.contentView.alpha = 0
            

            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.view.addSubview(blurEffectView)
            sender.center = topController.view.center
            topController.view.addSubview(sender)
            
            sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            sender.alpha = 1
            UIView.animate(withDuration: 0.4) {
                sender.alpha = 0.85
                //controller.visualEffect.alpha = 0.5
                sender.transform = CGAffineTransform.identity
            }
            

            
        }
        
    }
    
    
    static func animateOut (sender: UIView) {
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    for tempView in topController.view.subviews{
                        if let blurView = tempView as? UIVisualEffectView{
                            UIView.animate(withDuration: 0.4) {
                                blurView.alpha = 0
                            }
                            blurView.removeFromSuperview()
                        }
                    }
        UIView.animate(withDuration: 0.4, animations: {
            sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            sender.alpha = 0
            
        }) { (success:Bool) in
            sender.removeFromSuperview()
        }
        }
    }
    static func loadUserData(){
        let user = Auth.auth().currentUser
        if (user == nil) {return}
        let ref = Database.database().reference()
        ref.child("user").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let phone = value["phone"] as? String ?? ""
                let name = value["name"] as? String ?? ""
                let favBarber = value["favbarber"] as? Int ?? -1
                let userType = value["usertime"] as? Int ?? 1
                let mail = user?.email
                self.loggedUser = User(name: name, mail: mail!, phone: phone, userType: userType, favBarberId: favBarber)
                print(self.loggedUser.favBarberId)
                self.loadCurrentShop()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    static func loadCurrentShop(){
        let user = Auth.auth().currentUser
        if (user == nil) {return}
        let ref = Database.database().reference()
        ref.child("barbers").child(String(self.loggedUser.favBarberId)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                let barberName = value["name"] as? String ?? "NoName"
                let barberDesc = value["description"] as? String ?? "NoDesc"
                let barberPhone = value["phone"] as? String ?? "NoPhone"
                let barberAddress = (value["address"])! as? String ?? "NoAddress"
                
                var barberServices:[Service] = []
                if let child = snapshot.childSnapshot(forPath: "services").value as? NSArray {
                    for c in child{
                        if let tempServiceChild = c as? [String:Any]{
                            let serviceName = tempServiceChild["name"] as? String ?? "NoName"
                            let serviceDuration = tempServiceChild["duration"] as? Int ?? 0
                            let servicePrice = tempServiceChild["price"] as? Int ?? 0
                            let service = Service(name: serviceName, duration: serviceDuration, price: servicePrice)
                            barberServices.append(service)
                        }
                    }
                }
                var hours : [String:[[Int]]] = [:]
                if let child = snapshot.childSnapshot(forPath: "hours").value as? [String:Any]  {
                    
                    for c in child{
                        hours[c.key] = []
                        if let smallChild = snapshot.childSnapshot(forPath: "hours/\(c.key)").value as? NSArray  {
                            for smallC in smallChild{
                                if let tempTime = smallC as? [String:Any]{
                                    
                                    let open = tempTime["open"] as? Int ?? 0
                                    let close = tempTime["close"] as? Int ?? 0
                                    
                                    hours[c.key]?.append([open,close])
                                    
                                }
                            }
                        }
                    }
                }
                self.currentShop = Shop(ID: self.loggedUser.favBarberId, name: barberName, desc: barberDesc, phone: barberPhone, address: barberAddress, services: barberServices, hours: hours)
                print(self.currentShop.hours!)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
