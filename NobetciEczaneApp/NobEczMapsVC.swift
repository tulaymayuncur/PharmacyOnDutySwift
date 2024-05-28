import UIKit
import MapKit

class NobEczMapsVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var nobEczListe: [NobEczData] = []
    var secilenIlce: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addAnnotations()
    }
    
    func addAnnotations() {
        var annotations: [MKPointAnnotation] = []
        
        for eczane in nobEczListe {
            if let coordinate = eczane.coordinate {
                let annotation = MKPointAnnotation()
                annotation.title = eczane.name
                annotation.subtitle = eczane.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                annotations.append(annotation)
            }
        }
        
        mapView.showAnnotations(annotations, animated: true)
        
        if let firstEczane = nobEczListe.first, let firstCoordinate = firstEczane.coordinate {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstCoordinate.latitude, longitude: firstCoordinate.longitude), latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension NobEczMapsVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "PharmacyAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
