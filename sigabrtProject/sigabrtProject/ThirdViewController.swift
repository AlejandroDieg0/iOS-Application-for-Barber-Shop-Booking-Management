
import UIKit

class ThirdViewController: UIViewController {

    @IBAction func changedValueSwitch(_ sender: Any) {
        if let sw = sender as? UISwitch{
            UserDefaults.standard.set(sw.isOn, forKey: "disableWizard")
        }
    }
}
