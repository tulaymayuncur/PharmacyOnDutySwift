//
//  IlIlceModel.swift
//  NobetciEczaneApp
//
//  Created by Tülay MAYUNCUR on 4.11.2023.
//

import Foundation

struct IlModel: Codable {
    let data: [IlData]
}

struct IlData: Codable {
    let il_adi: String
    let ilceler: [Ilce]

}

struct Ilce: Codable {
    let il_adi: String
    let ilce_adi: String
    
    init(il_adi: String, ilce_adi: String) {
        self.il_adi = il_adi
        self.ilce_adi = ilce_adi
    }
}
