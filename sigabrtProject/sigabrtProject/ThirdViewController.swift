//
//  ThirdViewController.swift
//  sigabrtProject
//
//  Created by Francesco Molitierno on 18/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class ThirdViewController: UITableViewController {

    @IBAction func changedValueSwitch(_ sender: Any) {
        if let sw = sender as? UISwitch{
            UserDefaults.standard.set(sw.isOn, forKey: "disableWizard")
        }
    }
}
