import Foundation

struct NobEczModel: Codable {
    let success: Bool
    let result: [NobEczData]
}

struct NobEczData: Codable {
    let name: String
    let dist: String
    let address: String
    let phone: String
    let loc: String
    
    var coordinate: (latitude: Double, longitude: Double)? {
        let components = loc.split(separator: ",")
        if components.count == 2,
           let lat = Double(components[0]),
           let lon = Double(components[1]) {
            return (lat, lon)
        }
        return nil
    }
}
