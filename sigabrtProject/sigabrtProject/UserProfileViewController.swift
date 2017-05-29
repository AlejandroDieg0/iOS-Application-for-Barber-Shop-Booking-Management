
import UIKit
import Firebase
import FBSDKLoginKit

class UserProfileViewController: UITableViewController {

    var x = ""
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
    @IBOutlet var reauthView: UIView!
    
    //INFO LABEL
    @IBOutlet weak var changeMail: UITextField!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var helloName: UILabel!
    @IBOutlet weak var changePhone: UITextField!
    @IBOutlet weak var labelFavBarber: UILabel!
    
    // REAUTH
    @IBOutlet weak var reauthPassword: UITextField!
    @IBOutlet weak var sendMailPwReset: UIButton!
    
    // ICON
    @IBOutlet weak var userNameIcon: UIImageView!
    @IBOutlet weak var mailIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let editBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: Selector(("setEditing")))
        navigationItem.rightBarButtonItem = editButtonItem
        
        //GESTURE
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        self.changeName.isUserInteractionEnabled = false
        self.changeMail.isUserInteractionEnabled = false
        self.changePhone.isUserInteractionEnabled = false

        
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
                
                self.changeName.text = Funcs.loggedUser.name
                self.changePhone.text = Funcs.loggedUser.phone
                self.changeMail.text = Funcs.loggedUser.mail
                self.helloName.text = "Hello \(self.changeName.text!)"
                
                if Funcs.loggedUser != nil{
                    labelFavBarber.text = "DA SISTEMARE"
                } else {
                    labelFavBarber.text = "No favourite barber selected"
                }
            } else {
                print("no logged with Firebase")
                helloName.text = "Hello User!"
            }
        }
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // logout
    
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
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
        animateIn(sender: reauthView)
        Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
            // ...
        }

        return
    }
    

    
    // update del nome
    
    
    func animateIn(sender: UIView) {
        //        let xPosition = view.center as CGFloat
        //        let yPosition = view.center.y - 20
        //
        //        let height = 330 as CGFloat
        //        let width = 260 as CGFloat
        //
        //        sender.frame = CGRect(x: xPosition,y: yPosition,width: width,height: height)
        sender.center = self.view.center
        self.view.addSubview(sender)
        
        sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        sender.alpha = 0
        UIView.animate(withDuration: 0.4) {
            sender.alpha = 0.9
            
            
            sender.transform = CGAffineTransform.identity
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            print(editing)
            self.changePhone.isUserInteractionEnabled = true
            self.changePhone.textColor = UIColor.black
            
            self.changeMail.isUserInteractionEnabled = true
            self.changeMail.textColor = UIColor.black

            self.changeName.isUserInteractionEnabled = true
            self.changeName.textColor = UIColor.black


        } else {
            let ref = Database.database().reference().child("user/\(Auth.auth().currentUser?.uid ?? "noLogin")")
            ref.updateChildValues([
                "name": self.changeName.text!,
                "phone": self.changePhone.text!,
                ])
            
            self.changePhone.isUserInteractionEnabled = false
            self.changePhone.textColor = UIColor.gray
            
            self.changeMail.isUserInteractionEnabled = false
            self.changeMail.textColor = UIColor.gray
            
            self.changeName.isUserInteractionEnabled = false
            self.changeName.textColor = UIColor.gray

            print("Changes Uploaded")

        }
    }
    
    func animateOut (sender: UIView) {
        UIView.animate(withDuration: 0.4, animations: {
            sender.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            sender.alpha = 0
            
        }) { (success:Bool) in
            sender.removeFromSuperview()
        }
    }


    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //    func finishEdit(){
    //        let actionSheet = UIAlertController(title: "", message: "Confirm prenotation", preferredStyle: .actionSheet)
    //        let errorAlert = UIAlertController(title: "Missing Informations", message: "Please check the details of your reservations", preferredStyle: .actionSheet)
    //
    //        actionSheet.addAction(UIAlertAction(title: "OK", style: .default)
    //
    //
    //        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
    //        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    //
    //
    //            self.present(errorAlert, animated: true, completion:  nil)
    //
    //
    //            self.present(actionSheet, animated: true, completion:  nil)
    //         }
    

}
