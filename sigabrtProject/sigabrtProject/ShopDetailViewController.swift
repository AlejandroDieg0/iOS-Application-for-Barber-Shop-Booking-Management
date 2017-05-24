//
//  ShopDetailViewController.swift
//  sigabrtProject
//
//  Created by Feliciano Cindolo on 22/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit
import Nuke

class ShopDetailViewController: UIViewController {
    
    var barber : Shop?
    
    @IBOutlet weak var imageBarberShop: UIImageView!
    @IBOutlet weak var labelBarberName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    @IBOutlet weak var labelHours: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(barber!.desc)
        labelBarberName.text = barber?.name
        labelDescription.text = barber?.desc
        labelAddress.text = barber?.address
        labelPhone.text = barber?.phone
        Nuke.loadImage(with: (barber?.logo)!, into: imageBarberShop)
        labelHours.text = "Oradio di apertura: \((barber?.hours[0][0])!/60):00"
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
