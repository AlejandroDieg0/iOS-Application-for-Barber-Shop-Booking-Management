
import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var personalMap: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000000
    var pins: [MKPointAnnotation] = []
    
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
