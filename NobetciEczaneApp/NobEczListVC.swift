import UIKit

class NobEczListVC: UIViewController {
    
    @IBOutlet weak var nobEczTableView: UITableView!
    
    var nobEczListe = [NobEczData]()
    var secilenIl: String = ""
    var secilenIlce: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nobEczTableView.delegate = self
        nobEczTableView.dataSource = self
        fetchNobEczData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNobEczData()
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
                    // Gelen veriyi yazdırarak kontrol edin
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Gelen veri: \(jsonString)")
                    }
                    
                    let gelenNobEcz = try JSONDecoder().decode(NobEczModel.self, from: data)
                    let gelenNobEczList = gelenNobEcz.result
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
              cell.EczUzaklikLabel.text = nobEcz.loc
          }
          
          return cell
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if !nobEczListe.isEmpty {
                print("Tıklandı \(indexPath.row)")
            }
        }


}
