//
//  ShopDetailViewController.swift
//  sigabrtProject
//
//  Created by Feliciano Cindolo on 22/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class ShopDetailViewController: UIViewController {
    
    var barber : Shop?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(barber!.desc)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoBooking"{
            let secondVC = segue.destination as! UserReservationViewController
            secondVC.selectedShop = barber!
        }
    }
    
}