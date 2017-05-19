//
//  Funcs.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 19/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class Funcs: NSObject {

    static func animateIn(sender: UIView) {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = topController.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            topController.view.addSubview(blurEffectView)
            

            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            sender.center = topController.view.center
            topController.view.addSubview(sender)
            
            sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            sender.alpha = 0
            UIView.animate(withDuration: 0.4) {
                sender.alpha = 0.85
                //controller.visualEffect.alpha = 0.5
                sender.transform = CGAffineTransform.identity
            }
        }
        
    }
    
    
    static func animateOut (sender: UIView) {
                if let topController = UIApplication.shared.keyWindow?.rootViewController {
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
