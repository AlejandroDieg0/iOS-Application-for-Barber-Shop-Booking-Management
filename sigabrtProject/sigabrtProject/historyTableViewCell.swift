//
//  historyTableViewCell.swift
//  sigabrtProject
//
//  Created by Fabio on 29/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class historyTableViewCell: UITableViewCell {

    @IBOutlet weak var servizi: UILabel!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
