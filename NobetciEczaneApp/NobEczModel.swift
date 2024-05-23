//
//  NobEczModel.swift
//  NobetciEczaneApp
//
//  Created by Tülay MAYUNCUR on 3.11.2023.
//

import Foundation

class NobEczModel: Codable {
    let success: Bool
    let result: [NobEczData]
}

class NobEczData: Codable {
    let name: String?
    let dist: String?
    let address: String?
    let phone: String?
    let loc: String?

    init(name: String, dist: String, address: String, phone: String, loc: String) {
        self.name = name
        self.dist = dist
        self.address = address
        self.phone = phone
        self.loc = loc
    }
}
