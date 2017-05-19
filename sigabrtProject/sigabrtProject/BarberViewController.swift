//
//  BarberViewController.swift
//  sigabrtProject
//
//  Created by Antonio Colella on 19/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class BarberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    var Reservations:[Reservation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1440/15 //MinutiDelGiorno su Durata
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath) as! ReservationTableViewCell
//        aCell.labelName =
//        aCell.labelServices =
//        aCell.labelPrice
        return aCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "\(Int((section*15)/60)):\(Int((section*15)%60))"
    }
    
}
