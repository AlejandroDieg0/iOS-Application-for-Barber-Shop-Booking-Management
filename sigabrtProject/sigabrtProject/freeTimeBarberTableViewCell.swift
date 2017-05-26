
import UIKit

class freeTimeBarberCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    
    
    override func draw(_ rect: CGRect) { //Your code should go here.
        super.draw(rect)
        self.layer.cornerRadius = self.layer.frame.size.height / 2
//        self.layer.masksToBounds = true
//        // self.layer.bound
//        // self.layer.cornerRadius = 6
        self.label.textAlignment = NSTextAlignment.center
        // self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
