
import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var personalMap: MKMapView!
    
    let regionRadius: CLLocationDistance = 1500
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let myPosition = CLLocationCoordinate2D(latitude: Double("41.8")!, longitude: Double("1.3")!)
        let pin = MKPointAnnotation()
        pin.coordinate = myPosition
        pin.title = "Barber Shop"
        pin.subtitle = "Here you are"
        personalMap.addAnnotation(pin)
        self.personalMap.delegate = self
        personalMap.setRegion(MKCoordinateRegionMakeWithDistance(myPosition, regionRadius, regionRadius), animated: true)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        
        return annotationView
    }

    
}
