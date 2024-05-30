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
        if annotation is MKUserLocation {
            return nil // Canlı konum göstergesini varsayılan olarak kullan
        } else {
            let identifier = "PharmacyAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let callButton = UIButton(type: .contactAdd)
                callButton.tag = 1
                annotationView?.leftCalloutAccessoryView = callButton
                
                let directionsButton = UIButton(type: .detailDisclosure)
                directionsButton.tag = 2
                annotationView?.rightCalloutAccessoryView = directionsButton
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        
        if control.tag == 1 {
            // Arama butonu tıklandı
            if let phone = nobEczListe.first(where: { $0.name == annotation.title })?.phone {
                let cleanedPhone = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
                if let phoneUrl = URL(string: "tel://\(cleanedPhone)") {
                    if UIApplication.shared.canOpenURL(phoneUrl) {
                        UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
                    } else {
                        print("Telefon araması yapılamıyor: \(phoneUrl)")
                    }
                }
            }
        } else if control.tag == 2 {
            // Yol tarifi butonu tıklandı
            let coordinate = annotation.coordinate
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = annotation.title ?? "Bilinmeyen Konum"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}

extension NobEczMapsVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        mapView.showsUserLocation = true // Canlı konum göstergesini etkinleştir
        
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
}
