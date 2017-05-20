
import UIKit
import MapKit
import Firebase
import Nuke
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate, ModernSearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var personalMap: MKMapView!
    
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    
    var locManager = CLLocationManager()
    
    
    let regionRadius: CLLocationDistance = 20000
    var pins: [MKPointAnnotation: Shop] = [:]
    var TempID: Int = 0
    var barbers: [Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let myPosition = CLLocationCoordinate2D(latitude: Double("41.9102399")!, longitude: Double("12.2551245")!)
        /*personalMap.setRegion(MKCoordinateRegionMakeWithDistance(myPosition, regionRadius, regionRadius), animated: true)*/
        
        
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        drawMap()
        self.modernSearchBar.delegateModernSearchBar = self
        
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
            return
        }
        let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as? LoginViewController
        
        self.addChildViewController(controller!)
        Funcs.animateIn(sender: (controller?.loginView)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //let location = locations[0]
        
        //let span:MKCoordinateSpan = MKCoordinateSpanMake(0.5, 0.5)
        //let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        //personalMap.setRegion(region, animated: true)
        self.personalMap.showsUserLocation = true
    }
    
    func drawMap(){
        var ref: DatabaseReference!
        
        ref = Database.database().reference().child("barbers")
        
        ref.observe(.childAdded, with: { snapshot in
            if let snapshotValue = snapshot.value as? [String:Any] {
                let barberName = (snapshotValue["name"])! as! String
                let barberDesc = (snapshotValue["description"])! as! String
                let barberLat = snapshotValue["latitude"] as! Double
                let barberLon = (snapshotValue["longitude"])! as! Double
                let ID = Int(snapshot.key)!
                let barberPhone = (snapshotValue["phone"])! as! String
                let barberAddress = (snapshotValue["address"])! as! String
                
                let tempPin : MKPointAnnotation = MKPointAnnotation()
                
                tempPin.title = barberName
                tempPin.subtitle = barberDesc
                tempPin.coordinate = CLLocationCoordinate2D(latitude: Double(barberLat), longitude: Double(barberLon))
                print(barberName)
                let imageURL = Storage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("barbers/\(ID).png")
                
                imageURL.downloadURL(completion: { (url, error) in
                    
                    self.pins[tempPin] = Shop(ID: ID, name: barberName, desc: barberDesc, coordinate: tempPin.coordinate, phone: barberPhone, address: barberAddress, logo: url)
                    
                    self.personalMap.addAnnotation(tempPin)
                    self.initializeSearchBar()
                    
                })
                
            }
            self.initializeSearchBar()
            
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "sigabrt")
        let tempAnnotation = annotation as? MKPointAnnotation
        
        let shop = self.pins[tempAnnotation!]
        let barberLogo : UIImageView = UIImageView(image: #imageLiteral(resourceName: "pin"))
        
        
        pin.pinTintColor = UIColor.black
        pin.canShowCallout = true
        pin.animatesDrop = true
        
        
        Nuke.loadImage(with: (shop?.logo)!, into: barberLogo)
        
        pin.leftCalloutAccessoryView = barberLogo
        
        
        let button = UIButton(type: .detailDisclosure) as UIButton // button with info sign
        pin.rightCalloutAccessoryView = button
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let tempAnnotation = view.annotation as? MKPointAnnotation
        let shop = self.pins[tempAnnotation!]
        if control == view.rightCalloutAccessoryView{
            
            performSegue(withIdentifier: "userReservation", sender: shop)
            
        }
    }
    
    func onClickItemWithUrlSuggestionsView(item: ModernSearchBarModel) {
        print("User touched this item: "+item.title+" with this url: "+item.url.description)
        let selectedPin = findKeyForValue(value: item.url.description, shops: self.pins)!
        //  info1 = findKeyForValue(value: item.url.description, shops: self.pins)!
        self.personalMap.selectAnnotation(selectedPin, animated: true)
    }
    
    func findKeyForValue(value: String, shops: [MKPointAnnotation: Shop]) ->MKPointAnnotation?
    {
        for (key, shop) in shops
        {
            if (shop.logo?.absoluteString.contains(value))!
            {
                return key
            }
        }
        
        return nil
    }
    
    func initializeSearchBar(){
        var barberList = Array<ModernSearchBarModel>()
        for barber in self.pins.values {
            barberList.append(ModernSearchBarModel(title: barber.name, url: barber.logo!))
        }
        
        self.modernSearchBar.setDatasWithUrl(datas: barberList)
    }
    
}
