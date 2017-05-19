
import UIKit
import MapKit
import Firebase
import Nuke


class MapViewController: UIViewController,MKMapViewDelegate, ModernSearchBarDelegate {
    
    @IBOutlet weak var personalMap: MKMapView!
    
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    
    
    let regionRadius: CLLocationDistance = 1000
    var pins: [MKPointAnnotation: Shop] = [:]
    var TempID: Int = 0
    var barbers: [Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myPosition = CLLocationCoordinate2D(latitude: Double("41.9102399")!, longitude: Double("12.2551245")!)
        
        self.personalMap.delegate = self
        personalMap.setRegion(MKCoordinateRegionMakeWithDistance(myPosition, regionRadius, regionRadius), animated: true)
        drawMap()
        self.modernSearchBar.delegateModernSearchBar = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func drawMap(){
        var ref: DatabaseReference!
        
        ref = Database.database().reference().child("barbers")
        
        ref.observe(.childAdded, with: { snapshot in
            if let snapshotValue = snapshot.value as? [String:Any],
                let currentData = snapshotValue["barber"] as? [String:Any] {
                let barberName = (currentData["name"])! as! String
                let barberDesc = (currentData["description"])! as! String
                let barberLat = currentData["latitude"] as! Double
                let barberLon = (currentData["longitude"])! as! Double
                let ID = (currentData["id"])! as! Int
                let barberPhone = (currentData["phone"])! as! String
                let barberAddress = (currentData["address"])! as! String
                
                let tempPin : MKPointAnnotation = MKPointAnnotation()
                
                tempPin.title = barberName
                tempPin.subtitle = barberDesc
                tempPin.coordinate = CLLocationCoordinate2D(latitude: Double(barberLat), longitude: Double(barberLon))
                
                let imageURL = Storage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("barbers/\(String(ID)).png")
                
                imageURL.downloadURL(completion: { (url, error) in
                    
                    self.pins[tempPin] = Shop(ID: ID, name: barberName, desc: barberDesc, coordinate: tempPin.coordinate, phone: barberPhone, address: barberAddress, logo: url)
                    
                    self.personalMap.addAnnotation(tempPin)
                    self.initializeSearchBar()
                    
                })
                print(barberLat)
                
            }
            self.initializeSearchBar()
            
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "sigabrt")
        let tempAnnotation = annotation as? MKPointAnnotation
        let shop = self.pins[tempAnnotation!]
        let barberLogo : UIImageView = UIImageView(image: #imageLiteral(resourceName: "pin"))
        
        
        
        pin.pinTintColor = UIColor.black
        pin.canShowCallout = true
        pin.animatesDrop = true
        
        
        Nuke.loadImage(with: (shop?.logo)!, into: barberLogo)
        
        pin.leftCalloutAccessoryView = barberLogo
        
        return pin
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
