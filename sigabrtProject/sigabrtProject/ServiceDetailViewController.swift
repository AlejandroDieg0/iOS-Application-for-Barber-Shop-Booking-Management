//
//  ServiceDetailViewController.swift
//  sigabrtProject
//
//  Created by Feliciano Cindolo on 30/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class ServiceDetailViewController: UIViewController {
    var selectedService: Service!
    
    @IBOutlet weak var serviceName: UITextField!
    @IBOutlet weak var serviceDuration: UITextField!
    @IBOutlet weak var servicePrice: UITextField!
    @IBOutlet weak var deleteService: UIButton!
    @IBOutlet weak var updateDetail: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceName.text = selectedService.name
        servicePrice.text = String(selectedService.price)
        serviceDuration.text = String(selectedService.duration)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
