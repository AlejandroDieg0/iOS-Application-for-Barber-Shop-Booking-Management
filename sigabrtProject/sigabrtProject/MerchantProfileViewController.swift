
import UIKit
import Firebase
import FBSDKLoginKit


class MerchantProfileViewController: UITableViewController {
    
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    static var myShop : Shop!
    //INFO LABEL
    @IBOutlet weak var changeMail: UITextField!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var helloName: UILabel!
    @IBOutlet weak var changePhone: UITextField!
    @IBOutlet weak var logoBarber: UIImageView!
    @IBOutlet weak var shopAddress: UITextField!
    @IBOutlet weak var shopDescription: UITextField!
    
    @IBOutlet weak var sendMailPwReset: UIButton!

    //  var myContainerViewDelegate: BarberDetailViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoBarber.layer.cornerRadius = logoBarber.frame.size.width/2

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(MerchantProfileViewController.editing),
                name: NSNotification.Name(rawValue: "editTableView"),
                object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MerchantProfileViewController.doneEditing),
            name: NSNotification.Name(rawValue: "doneTableView"),
            object: nil)
        
        //GESTURE
        self.hideKeyboardWhenTappedAround()
        
        self.changeName.isUserInteractionEnabled = false
        self.changeMail.isUserInteractionEnabled = false
        self.changePhone.isUserInteractionEnabled = false
        self.shopAddress.isUserInteractionEnabled = false
        self.shopDescription.isUserInteractionEnabled = false
        
        
        if(FBSDKAccessToken.current() != nil){
            
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,email, picture.type(large)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(String(describing: error))")
                }
                else
                {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    print(data)
                    let firstName = data["first_name"]
                    
                    self.helloName.text = "Hello \(firstName!)"
                    self.changeName.text = firstName! as? String
                    self.changeMail.text = data["email"] as? String
                    self.sendMailPwReset.setTitle("Connected as \(firstName!)", for: .normal)
                    
                }
            })
            
        }else{
            if Auth.auth().currentUser != nil {
                self.changeName.text = barberProfileViewController.myShop.name
                self.changePhone.text = barberProfileViewController.myShop.phone
                self.changeMail.text = Funcs.loggedUser.mail
                self.helloName.text = "Hello \(Funcs.loggedUser.name)"
                self.shopAddress.text = barberProfileViewController.myShop.address
                self.shopDescription.text = barberProfileViewController.myShop.desc

                
            } else {
                print("no logged with Firebase")
                helloName.text = "Hello User!"
            }
        }
        
        
    }

    func reloadData(){
            self.tableView.reloadData()
           }

    func editing(){
        print("sono qui dento")
        self.changePhone.isUserInteractionEnabled = true
        self.changePhone.textColor = UIColor.black
        self.changePhone.borderStyle = .roundedRect
        
        self.changeMail.isUserInteractionEnabled = true
        self.changeMail.textColor = UIColor.black
        self.changeMail.borderStyle = .roundedRect

        
        self.changeName.isUserInteractionEnabled = true
        self.changeName.textColor = UIColor.black
        self.changeName.borderStyle = .roundedRect

        
        self.shopDescription.isUserInteractionEnabled = true
        self.shopDescription.textColor = UIColor.black
        self.shopDescription.borderStyle = .roundedRect

        
        self.shopAddress.isUserInteractionEnabled = true
        self.shopAddress.textColor = UIColor.black
        self.shopAddress.borderStyle = .roundedRect

        
    }
    
    func doneEditing() {
        let ref = Database.database().reference().child("barbers/\(barberProfileViewController.myShop.ID)")
        ref.updateChildValues([
            "name": self.changeName.text!,
            "phone": self.changePhone.text!,
            "address": self.shopAddress.text!,
            "description": self.shopDescription.text!
            ])


        self.changePhone.isUserInteractionEnabled = false
        self.changePhone.textColor = UIColor.gray
        self.changePhone.borderStyle = .none

        self.changeMail.isUserInteractionEnabled = false
        self.changeMail.textColor = UIColor.gray
        self.changeMail.borderStyle = .none

        self.changeName.isUserInteractionEnabled = false
        self.changeName.textColor = UIColor.gray
        self.changeName.borderStyle = .none

        self.shopDescription.isUserInteractionEnabled = true
        self.shopDescription.textColor = UIColor.black
        self.shopDescription.borderStyle = .none
        
        
        self.shopAddress.isUserInteractionEnabled = true
        self.shopAddress.textColor = UIColor.black
        self.shopAddress.borderStyle = .none
        
        print("Changes Uploaded")
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.navigationController?.popViewController(animated: true)
        return
    }
    
    // Delete profile
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        user?.delete { error in
            if error != nil {
                // An error happened.
            } else {
                // Account deleted.
                self.dismiss(animated: true, completion: nil)
            }
        }
        return
    }
    
    // Send mail for password reset
    
    @IBAction func sendMailPwReset(_ sender: Any) {
        guard let mail = self.changeMail.text, !mail.isEmpty else {
            return
        }
            Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
            // ...
        }
        
        return
    }
    // REAUTH
    func createAlert(){
        let alert = UIAlertController(title: "Authentication", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (password) in
            password.placeholder = "Current Password"
            password.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
         self.present(alert, animated: true)
    }

}
