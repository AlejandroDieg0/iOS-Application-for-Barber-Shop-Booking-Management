import UIKit
import FSCalendar
import Nuke
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import UITextField_Shake

class UserReservationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // LOGIN
    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet var loginView: UIView!
    @IBOutlet var signupView: UIView!
    
    @IBOutlet var confirmPrenotation: UIView!
    @IBOutlet weak var prenotationDate: UILabel!
    @IBOutlet weak var prenotationHour: UILabel!
    @IBOutlet weak var prenotationTotal: UILabel!
    
    
    @IBOutlet weak var passw: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var signUpMail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var loginError: UILabel!
    
    @IBOutlet weak var noTime: UILabel!
    @IBOutlet weak var noHour: UILabel!
    
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var barbershopName: UILabel!
    @IBOutlet weak var barbershopPhone: UILabel!
    @IBOutlet weak var barbershopAddress: UILabel!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var barberPhoto: UIImageView!
    var loadingAnimation: UIAlertController!
    
    let slotSizeInMinutes = 15
    var selectedDate : Date = Date()
    var selectedTimeInMinutes = 0
    var selectedShop: Shop!
    var selectedServices : [Service] = []
    var selectedDuration = 0
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noTime.alpha = 0
        noHour.alpha = 0
        // LGIN
        self.hideKeyboardWhenTappedAround()
        
        loadingAnimation = Funcs.inizializeLoadAnimation()
        
        logIn.backgroundColor = UIColor.clear
        logIn.layer.borderWidth = 1.3
        logIn.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
        signUp.backgroundColor = UIColor.clear
        signUp.layer.borderWidth = 1.3
        signUp.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
        barberPhoto.layer.cornerRadius = barberPhoto.frame.size.width/2
        barberPhoto.clipsToBounds = true
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        timeCollectionView.allowsMultipleSelection = false
        servicesCollectionView.allowsMultipleSelection = true
        self.calendar.accessibilityIdentifier = "calendar"
        self.calendar.select(Date())
        self.calendar.scope = .week
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.servicesCollectionView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        present(loadingAnimation, animated: true, completion: {
            if(self.selectedShop == nil){
                Funcs.loadShop(){loadedShop in
                    self.selectedShop = loadedShop
                    self.loadInitialInfos()
                    self.servicesCollectionView.reloadData()
                }
            } else {
                self.loadInitialInfos()
            }
        })
    }
    
    func loadInitialInfos() {
        self.barbershopName.text = self.selectedShop.name
        self.barbershopPhone.text = self.selectedShop.phone
        self.barbershopAddress.text = self.selectedShop.address
        
        Funcs.busySlots(shop: self.selectedShop, date: self.selectedDate, duration: self.selectedDuration, collection: self.timeCollectionView)
        self.loadingAnimation.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        error.alpha = 0
        loginError.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        //Auth.auth().removeStateDidChangeListener(handle!)
        // [END remove_auth_listener]
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.servicesCollectionView.contentOffset.y <= -self.servicesCollectionView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        let today = Date()
        
        return today
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        self.selectedTimeInMinutes = 0
        Funcs.busySlots(shop: selectedShop, date: date, duration: self.selectedDuration, collection: timeCollectionView)
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.servicesCollectionView) {
            if (selectedShop == nil) {return 0}
            return selectedShop.services.count
        } else {
            let x = Funcs.bookableSlotsInMinutes.count
            if x == 0 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.noTime.alpha = 1
                    self.noHour.alpha = 0
                })
                
            }
            else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.noTime.alpha = 0
                    self.noHour.alpha = 1
                })
                
            }
            return Funcs.bookableSlotsInMinutes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.servicesCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defCell", for: indexPath) as!  ServiceCollectionViewCell
            
            cell.labelServiceName.text = selectedShop.services[indexPath.row].name
            cell.labelServicePrice.text = "\(selectedShop.services[indexPath.row].price) €"
            
            let imageURL = Storage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("services/\(selectedShop.services[indexPath.row].name.lowercased()).png")
            
            cell.imageViewService?.image = nil
            cell.indicator.startAnimating()
            imageURL.downloadURL(completion: { (url, error) in
                if url != nil {
                    Nuke.loadImage(with: url!, into: cell.imageViewService){response, _ in
                        cell.indicator.stopAnimating()
                        cell.imageViewService?.image = response.value
                        cell.setNeedsLayout()
                    }
                } else {
                    cell.imageViewService?.image = #imageLiteral(resourceName: "default")
                    cell.indicator.stopAnimating()
                }
            })
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "freeTimeCell", for: indexPath) as! freeTimeBarberCollectionViewCell
            cell.label.text = Funcs.minutesToHour(Funcs.bookableSlotsInMinutes[indexPath.row])
            
            let iPath = self.timeCollectionView.indexPathsForSelectedItems!
            if (iPath != []){
                let path : NSIndexPath = iPath[0] as NSIndexPath
                let rowIndex = path.row
                if (rowIndex == indexPath.row ){
                    cell.contentView.backgroundColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)
                    
                }else{
                    cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
                    
                }
                
            } else {
                cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (collectionView == self.servicesCollectionView) {
            self.selectedServices = self.selectedServices.filter { $0.name != selectedShop.services[indexPath.row].name }
            
            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.servicesCollectionView) {
            
            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            self.selectedServices.append(selectedShop.services[indexPath.row])
            
        } else {
            selectedTimeInMinutes = Funcs.bookableSlotsInMinutes[indexPath.row]
            
            for cell in self.timeCollectionView.visibleCells{
                cell.contentView.backgroundColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
            }
            
            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)
        }
    }
    
    @IBAction func saveReservation(_ sender: Any) {
        
        if(Auth.auth().currentUser == nil){
            Funcs.animateIn(sender: (loginView))
        } else {
            
            if (self.selectedTimeInMinutes == 0 ||  self.selectedServices.count == 0 ){
                
                let errorAlert = UIAlertController(title: "Missing Informations", message: "Please check the details of your reservations", preferredStyle: .actionSheet)
                
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(errorAlert, animated: true, completion:  nil)
            } else {
                Funcs.animateIn(sender: self.confirmPrenotation)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
                let data = dateFormatter.string(from:selectedDate as Date)
                var total = 0
                for service in selectedServices{
                    total += service.price
                }
                
                prenotationDate.text = data
                prenotationHour.text = Funcs.minutesToHour(selectedTimeInMinutes)
                prenotationTotal.text = String(total)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prenotationCell") as! prenotationConfirmTableViewCell
        
        cell.price.text = String(selectedServices[indexPath.row].price)
        cell.service.text = selectedServices[indexPath.row].name
        return cell
    }
    
    @IBAction func confirmPrenotation(_ sender: Any) {
        let note = "noNote"
        present(loadingAnimation, animated: true, completion: {
            Funcs.addReservation(shop: self.selectedShop, time: self.selectedTimeInMinutes, note: note, services: self.selectedServices, date: self.selectedDate){_ in
                
                self.selectedTimeInMinutes = 0
                self.selectedServices = []
                let selectedItems = self.servicesCollectionView.indexPathsForSelectedItems
                for indexPath in selectedItems! {
                    self.servicesCollectionView.deselectItem(at: indexPath, animated:true)
                    if self.servicesCollectionView.cellForItem(at: indexPath) != nil {
                        self.servicesCollectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                        
                    }
                }
                self.loadingAnimation.dismiss(animated: true, completion: {
                    Funcs.animateOut(sender: self.confirmPrenotation)
                })
            }
        })
    }
    
    @IBAction func noConfirm(_ sender: Any) {
        Funcs.animateOut(sender: confirmPrenotation)
    }
    
    @IBAction func showProfile(_ sender: Any) {
        if(Auth.auth().currentUser != nil){
            performSegue(withIdentifier: "showProfile", sender: nil)
        } else {
            Funcs.animateIn(sender: loginView)
        }
    }
    
    //MARK: Login
    @IBAction func login(_ sender: UIButton) {
        
        guard let email = self.email.text , !email.isEmpty else {
            //print("\n [Error] Write Username \n")
            self.email.shake()
            self.loginError.text = "Username empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.loginError.alpha = 1
            })
            
            return
        }
        
        guard let password = self.passw.text, !password.isEmpty else {
            //print("\n [Error] Write Password \n")
            self.passw.shake()
            self.loginError.text = "Password empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.loginError.alpha = 1
            })
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard error == nil else {
                // print(" \n [ERROR] Can't Sign In \n   withError: \( error!.localizedDescription) \n")
                // let alert = ErrorMessageView.createAlert(title: "Can't Sign In!", message: "(error!.localizedDescription)")
                //   self.show(alert, sender: nil)
                
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case AuthErrorCode.userNotFound:
                        self.loginError.text = "User not found"
                        self.email.shake()
                    case AuthErrorCode.invalidEmail:
                        self.loginError.text = "Invalid Email"
                        self.email.shake()
                    case AuthErrorCode.wrongPassword:
                        self.loginError.text = "Wrong password"
                        self.passw.shake()
                    default:
                        self.loginError.text = error!.localizedDescription
                        print("Login User Error: \(error!.localizedDescription)")
                    }
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.loginError.alpha = 1
                })
                return
            }
            print("Welcome \(user!.email! + "\n" + user!.uid)")
            self.email.text = ""
            self.passw.text = ""
            
            Funcs.animateOut(sender: self.loginView)
        })
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        guard let signUpMail = self.signUpMail.text , !signUpMail.isEmpty else {
            //print("\n [Error] Write Username \n")
            self.signUpMail.shake()
            self.error.text = "Email empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.error.alpha = 1
            })
            return
        }
        
        guard let signUpPassword = self.signUpPassword.text, !signUpPassword.isEmpty else {
            //print("\n [Error] Write Password \n")
            self.signUpPassword.shake()
            self.error.text = "Password empty"
            UIView.animate(withDuration: 0.3, animations: {
                self.error.alpha = 1
            })
            return
        }
        
        Auth.auth().createUser(withEmail: signUpMail, password: signUpPassword, completion: { (user, error) in
            
            guard error == nil else {
                print("Can't create an Account \n   withError: \(error!.localizedDescription) \n")
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case AuthErrorCode.invalidEmail:
                        self.error.text = "Invalid Email"
                        self.signUpMail.shake()
                    default:
                        self.error.text = error!.localizedDescription
                        self.signUpMail.shake()
                        self.signUpPassword.shake()
                    }
                }
                self.error.text = error!.localizedDescription
                UIView.animate(withDuration: 0.3, animations: {
                    self.error.alpha = 1
                })
                
                //let alert = ErrorMessageView.createAlert(title: "Can't create an Account!", message: "withError: \(error!.localizedDescription)")
                //self.show(alert, sender: nil)
                
                return
            }
            
            print("Welcome \(user!.email!)")
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                // handle error
            })
            
            Funcs.animateOut(sender: self.signupView)
        })
    }
    
    @IBAction func newAccount(_ sender: UIButton) {
        Funcs.animateOut(sender: loginView)
        Funcs.animateIn(sender: signupView)
    }
    
    @IBAction func alreadyHaveAccount(_ sender: UIButton) {
        Funcs.animateOut(sender: signupView)
        Funcs.animateIn(sender: loginView)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        Funcs.animateOut(sender: loginView)
    }
    
    @IBAction func fbLogin(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success:
                print("Logged in!")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    Funcs.animateOut(sender: self.loginView)
                }
            }
        }
    }
}


