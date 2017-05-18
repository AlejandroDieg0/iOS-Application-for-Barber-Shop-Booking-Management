
import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var personalMap: MKMapView!
    
    
    
    let regionRadius: CLLocationDistance = 1000000
    var pins: [MKPointAnnotation: Any] = [:]
    var TempID: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myPosition = CLLocationCoordinate2D(latitude: Double("41.9102399")!, longitude: Double("12.2551245")!)
        
        self.personalMap.delegate = self
        personalMap.setRegion(MKCoordinateRegionMakeWithDistance(myPosition, regionRadius, regionRadius), animated: true)
        drawMap()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func drawMap(){
        var ref: FIRDatabaseReference!
        
        ref = FIRDatabase.database().reference().child("barbers")
        
        ref.observe(.childAdded, with: { snapshot in
            if let snapshotValue = snapshot.value as? [String:Any],
                let currentData = snapshotValue["barber"] as? [String:Any] {
                let barberName = (currentData["name"])! as! String
                let barberDesc = (currentData["description"])! as! String
                let barberLat = currentData["latitude"] as! Double
                let barberLon = (currentData["longitude"])! as! Double
                self.TempID = (currentData["id"])! as! Int

                let tempPin : MKPointAnnotation = MKPointAnnotation()
                tempPin.title = barberName
                tempPin.subtitle = barberDesc
                
                tempPin.coordinate = CLLocationCoordinate2D(latitude: Double(barberLat), longitude: Double(barberLon))
                self.pins[tempPin]=currentData
                
                self.personalMap.addAnnotation(tempPin)
                print(barberLat)
               
            }
            
            
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "sigabrt")
        let tempAnnotation = annotation as? MKPointAnnotation
        let barber = self.pins[tempAnnotation!] as? [String:Any]
        let barberID = (barber?["id"])! as! Int

        pin.pinTintColor = UIColor.black
        pin.canShowCallout = true
        pin.animatesDrop = true
        
        let imageURL = FIRStorage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("barbers/\(String(barberID)).png")
        imageURL.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription as Any)
                pin.leftCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "pin"))
                return
            }
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    pin.leftCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "pin"))
                    return
                }
                
                guard let imageData = UIImage(data: data!) else { pin.leftCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "pin"));  return }
                pin.leftCalloutAccessoryView = UIImageView(image: imageData)
                
            }).resume()
            
        })

        return pin
    }
}
