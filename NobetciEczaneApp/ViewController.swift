import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nobetciEczaneLabel: UILabel!
    @IBOutlet weak var sehirSecmeTextField: UITextField!
    @IBOutlet weak var ilceSecmeTextField: UITextField!
    
    var sehirPickerView: UIPickerView?
    var ilcePickerView: UIPickerView?
    
    var sehirlerList: [IlData] = []
    var ilcelerList: [Ilce] = []
    
    var secilenIl: String?
    var secilenIlce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "il-ilce", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let ilModel = try JSONDecoder().decode(IlModel.self, from: jsonData)
                self.sehirlerList = ilModel.data
            } catch {
                print("JSON verilerini çözme hatası: \(error)")
            }
        } else {
            print("JSON dosyası bulunamadı.")
        }
        
        sehirPickerView = UIPickerView()
        sehirPickerView?.dataSource = self
        sehirPickerView?.delegate = self
        sehirSecmeTextField.inputView = sehirPickerView
        
        ilcePickerView = UIPickerView()
        ilcePickerView?.dataSource = self
        ilcePickerView?.delegate = self
        ilceSecmeTextField.inputView = ilcePickerView
        
        let sehirToolbar = UIToolbar()
        sehirToolbar.tintColor = UIColor.red
        sehirToolbar.sizeToFit()
        
        let SehirTamamButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.SehirTamamTikla))
        let SehirBoslukButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let SehirIptalButton = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(self.SehirIptalTikla))
        
        sehirToolbar.setItems([SehirIptalButton, SehirBoslukButton, SehirTamamButton], animated: true)
        sehirSecmeTextField.inputAccessoryView = sehirToolbar
        
        let ilceToolbar = UIToolbar()
        ilceToolbar.tintColor = UIColor.red
        ilceToolbar.sizeToFit()
        
        let IlceTamamButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.IlceTamamTikla))
        let IlceBoslukButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let IlceIptalButton = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(self.IlceIptalTikla))
        
        ilceToolbar.setItems([IlceIptalButton, IlceBoslukButton, IlceTamamButton], animated: true)
        ilceSecmeTextField.inputAccessoryView = ilceToolbar
    }
    
    @IBAction func ililceButton(_ sender: Any) {
        self.secilenIl = sehirSecmeTextField.text
        self.secilenIlce = ilceSecmeTextField.text
        performSegue(withIdentifier: "ilIlce", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ilIlce" {
            if let gidilecekVC = segue.destination as? NobEczListVC {
                gidilecekVC.secilenIl = self.secilenIl ?? "istanbul"
                gidilecekVC.secilenIlce = self.secilenIlce ?? "beykoz"
            }
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sehirPickerView {
            return sehirlerList.count
        } else if pickerView == ilcePickerView {
            return ilcelerList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == sehirPickerView {
            return sehirlerList[row].il_adi
        } else if pickerView == ilcePickerView {
            return ilcelerList[row].ilce_adi
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sehirPickerView {
            sehirSecmeTextField.text = sehirlerList[row].il_adi
            ilcelerList = sehirlerList[row].ilceler
            ilcePickerView?.reloadAllComponents()
        } else if pickerView == ilcePickerView {
            ilceSecmeTextField.text = ilcelerList[row].ilce_adi
        }
    }
    
    @objc func SehirTamamTikla() {
        view.endEditing(true)
    }
    
    @objc func SehirIptalTikla() {
        sehirSecmeTextField.text = ""
        sehirSecmeTextField.placeholder = "Lütfen İl Seçiniz"
        view.endEditing(true)
    }
    
    @objc func IlceTamamTikla() {
        view.endEditing(true)
    }
    
    @objc func IlceIptalTikla() {
        ilceSecmeTextField.text = ""
        ilceSecmeTextField.placeholder = "Lütfen İlçe Seçiniz"
        view.endEditing(true)
    }
}
