import UIKit
import CoreLocation

class NobEczListVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var nobEczTableView: UITableView!
    @IBOutlet weak var selectedLocationLabel: UIButton!
    @IBOutlet weak var dateLabel: UIButton!
    
    var nobEczListe = [NobEczData]()
    var secilenIl: String = ""
    var secilenIlce: String = ""
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nobEczTableView.delegate = self
        nobEczTableView.dataSource = self
        
        // Konum yöneticisini yapılandır
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        fetchNobEczData()
        
        selectedLocationLabel.setTitle("\(secilenIl) Nöbetçi Eczaneler", for: .normal)

        // Tarihi al ve butona ata
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Tarih formatı isteğe bağlı olarak değiştirilebilir
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        dateLabel.setTitle("\(dateString) Tarihi için Nöbetçi Eczaneler", for: .normal)
    }
    
    // Konum güncellemeleri alındığında çağrılır
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            nobEczTableView.reloadData() // Konum güncellendiğinde tabloyu yeniden yükleyin
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
    
    func fetchNobEczData() {
        let apiUrl = "https://api.collectapi.com/health/dutyPharmacy?ilce=\(secilenIlce)&il=\(secilenIl)"
        if let url = URL(string: apiUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("apikey 4RJ1iOmE3iMkZr9OVTm2cK:6xfEGNAUyQdAOevFBGDBGj", forHTTPHeaderField: "authorization")
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("Veri yok")
                    return
                }
                
                do {
                    let gelenNobEcz = try JSONDecoder().decode(NobEczModel.self, from: data)
                    var gelenNobEczList = gelenNobEcz.result
                    
                    if let currentLocation = self.currentLocation {
                        for i in 0..<gelenNobEczList.count {
                            let nobEcz = gelenNobEczList[i]
                            let eczaneLocation = nobEcz.loc
                            let eczaneCoordinates = eczaneLocation.split(separator: ",")
                            if eczaneCoordinates.count == 2,
                               let latitude = Double(eczaneCoordinates[0].trimmingCharacters(in: .whitespaces)),
                               let longitude = Double(eczaneCoordinates[1].trimmingCharacters(in: .whitespaces)) {
                                
                                let eczaneLocation = CLLocation(latitude: latitude, longitude: longitude)
                                let distance = currentLocation.distance(from: eczaneLocation) / 1000 // Mesafe kilometre cinsinden
                                gelenNobEczList[i].distance = distance
                            } else {
                                gelenNobEczList[i].distance = nil
                            }
                        }
                        // Mesafeye göre sıralama
                        gelenNobEczList.sort { ($0.distance ?? Double.greatestFiniteMagnitude) < ($1.distance ?? Double.greatestFiniteMagnitude) }
                    }
                    
                    self.nobEczListe = gelenNobEczList
                    
                    DispatchQueue.main.async {
                        self.nobEczTableView.reloadData()
                    }
                } catch {
                    print("JSON çözme hatası: \(error.localizedDescription)")
                }
            }.resume()
        } else {
            print("Geçersiz URL")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            if let mapVC = segue.destination as? NobEczMapsVC {
                mapVC.nobEczListe = self.nobEczListe
                mapVC.secilenIlce = self.secilenIlce
            }
        }
    }
}

extension NobEczListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nobEczListe.isEmpty ? 1 : nobEczListe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nobEczCell", for: indexPath) as! NobEczTableViewCell
        
        if nobEczListe.isEmpty {
            cell.eczAdiLabel.text = "Seçilen il ve ilçede açık nöbetçi eczane yok"
            cell.EczSemtLabel.text = ""
            cell.EczAdresLabel.text = ""
            cell.EczUzaklikLabel.text = ""
            cell.EczTelLabel.text = ""
        } else {
            let nobEcz = nobEczListe[indexPath.row]
            cell.eczAdiLabel.text = nobEcz.name
            cell.EczTelLabel.text = "Tel: \(nobEcz.phone)"
            cell.EczSemtLabel.text = nobEcz.dist
            cell.EczAdresLabel.text = nobEcz.address
            
            if let distance = nobEcz.distance {
                cell.EczUzaklikLabel.text = String(format: "Uzaklık: %.2f km", distance)
            } else {
                cell.EczUzaklikLabel.text = "Uzaklık hesaplanamadı"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !nobEczListe.isEmpty {
            print("Tıklandı \(indexPath.row)")
        }
    }
}
