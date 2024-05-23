//
//  ViewController.swift
//  NobetciEczaneApp
//
//  Created by Tülay MAYUNCUR on 11.10.2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var nobetciEczaneLabel: UILabel!
    
    @IBOutlet weak var sehirSecmeTextField: UITextField!
    var sehirPickerView:UIPickerView?
    
    @IBOutlet weak var ilceSecmeTextField: UITextField!
    var ilcePickerView:UIPickerView?
    
    var sehirlerList: [IlData] = []
    var ilcelerList: [Ilce] = []
    
    var secilenIl: String?
    var secilenIlce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "il-ilce", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                
                // JSONDecoder'ı kullanarak verileri çözün
                let ilModel = try JSONDecoder().decode(IlModel.self, from: jsonData)
                
                // Bütün illeri bir listeye alın
                let iller: [IlData] = ilModel.data
                self.sehirlerList = iller
                
                for ilData in iller {
                    for ilce in ilData.ilceler {
                        ilcelerList.append(ilce)
                    }
                }
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
        
        sehirToolbar.setItems([SehirIptalButton,SehirBoslukButton,SehirTamamButton], animated: true)
        sehirSecmeTextField.inputAccessoryView = sehirToolbar
        
        let ilceToolbar = UIToolbar()
        ilceToolbar.tintColor = UIColor.red
        ilceToolbar.sizeToFit()
        
        let IlceTamamButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(self.IlceTamamTikla))
        
        let IlceBoslukButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let IlceIptalButton = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(self.IlceIptalTikla))
        
        ilceToolbar.setItems([IlceIptalButton,IlceBoslukButton,IlceTamamButton], animated: true)
        ilceSecmeTextField.inputAccessoryView = ilceToolbar
        
    }
    
    @IBAction func ililceButton(_ sender: Any) {
        
        self.secilenIl = sehirSecmeTextField.text
        self.secilenIlce = ilceSecmeTextField.text
        
        print("Gönderilen İl: \(secilenIl ?? "Boş")")
        print("Gönderilen İlçe: \(secilenIlce ?? "Boş")")

        performSegue(withIdentifier: "ilIlce", sender:nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ilIlce" {
            if let gidilecekVC = segue.destination as? NobEczListVC {
                // Seçilen il ve ilçeyi alın
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
            // Seçilen il adını metin alanına atayın
            sehirSecmeTextField.text = sehirlerList[row].il_adi
            
            // Seçilen ilin ilçelerini ilcePickerView'da göstermek için
            ilcelerList = sehirlerList[row].ilceler
            ilcePickerView?.reloadAllComponents()
            print("Seçilen İl: \(sehirSecmeTextField.text ?? "")")

        } else if pickerView == ilcePickerView {
            // Seçilen ilçeyi metin alanına atayın
            ilceSecmeTextField.text = ilcelerList[row].ilce_adi
            print("Seçilen İlçe: \(ilceSecmeTextField.text ?? "")")

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


