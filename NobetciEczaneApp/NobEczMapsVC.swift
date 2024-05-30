import UIKit
import MapKit
import CoreLocation

class NobEczMapsVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var nobEczListe: [NobEczData] = []
    var secilenIlce: String = ""
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
        
        mapView.addAnnotations(annotations)
        
        if let firstEczane = nobEczListe.first, let firstCoordinate = firstEczane.coordinate {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstCoordinate.latitude, longitude: firstCoordinate.longitude), latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension NobEczMapsVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title == "Siz Buradasınız" {
            let identifier = "UserLocation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.pinTintColor = UIColor.blue // Kullanıcı konumu için özel renk
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        } else {
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
}

extension NobEczMapsVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        let userAnnotation = MKPointAnnotation()
        userAnnotation.title = "Siz Buradasınız"
        userAnnotation.coordinate = userLocation.coordinate
        mapView.addAnnotation(userAnnotation)
        
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()  // Konum güncellemelerini durdurur
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
}
