
import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var personalMap: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000000
    var pins: [MKPointAnnotation] = []
    
    let shop = Shop(name: "ECHÒ", desc: "Parrucchiere Uomo by Giulio Cerqua", coordinate: CLLocationCoordinate2D(latitude: Double("40.9230087")!, longitude: Double("14.1749905")!))
    let shop2 = Shop(name: "A. De Lucia", desc: "Parrucchiere Uomo by Antonio De Lucia", coordinate: CLLocationCoordinate2D(latitude: Double("45.4628886")!, longitude: Double("9.0373048")!))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let myPosition = CLLocationCoordinate2D(latitude: Double("41.9102399")!, longitude: Double("12.2551245")!)
//        let pin = MKPointAnnotation()
//        let pin2 = MKPointAnnotation()
//        let pin3 = MKPointAnnotation()
//        
//        pin.coordinate = myPosition
//        pin.title = "Barber Shop"
//        pin.subtitle = "Here you are"
//        
//        pin2.title = shop.name
//        pin2.subtitle = shop.desc
//        pin2.coordinate = shop.coordinate
//        
//        pin3.title = shop2.name
//        pin3.subtitle = shop2.desc
//        pin3.coordinate = shop2.coordinate
//        
//        personalMap.addAnnotation(pin)
//        personalMap.addAnnotation(pin2)
//        personalMap.addAnnotation(pin3)
        
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
                
                let tempPin : MKPointAnnotation = MKPointAnnotation()
                tempPin.title = barberName
                tempPin.subtitle = barberDesc
                
                tempPin.coordinate = CLLocationCoordinate2D(latitude: Double(barberLat), longitude: Double(barberLon))
                self.pins.append(tempPin)
                self.personalMap.addAnnotation(tempPin)
                print(barberLat)
            }
           

        })
            }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = true
            annotationView.image = #imageLiteral(resourceName: "pin")
        }
        return nil
        //return annotationView
    }

    
}
