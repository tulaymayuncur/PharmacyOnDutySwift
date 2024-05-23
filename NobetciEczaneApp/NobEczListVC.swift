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
            request.setValue("apikey 0NhzdC4EUi8CGIofVoldl7:0DzHv36yQ9Gjz5KKMIzyaz", forHTTPHeaderField: "authorization")
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil || data == nil {
                    print("Hata")
                    return
                }
                do {
                    let gelenNobEcz = try JSONDecoder().decode(NobEczModel.self, from: data!)
                    
                    // JSON verisi boşsa, gelenNobEcz.result listesinin boş olup olmadığını kontrol edin
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
        } else {
            let nobEcz = nobEczListe[indexPath.row]
            cell.eczAdiLabel.text = nobEcz.name ?? "N/A"
            cell.EczSemtLabel.text = nobEcz.dist ?? "N/A"
            cell.EczAdresLabel.text = nobEcz.address ?? "N/A"
            cell.EczUzaklikLabel.text = nobEcz.loc ?? "N/A"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !nobEczListe.isEmpty {
            print("Tıklandı \(indexPath.row)")
        }
    }
}
