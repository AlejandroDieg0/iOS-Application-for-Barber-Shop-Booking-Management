//
//  File.swift
//  sigabrtProject
//
//  Created by Fabio on 23/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class freeTimeBarberCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    
    
    override func draw(_ rect: CGRect) { //Your code should go here.
        super.draw(rect)
        self.layer.cornerRadius = self.frame.size.width / 2
    }
}
