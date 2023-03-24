import UIKit

struct User: Codable {
    let name: String
    let profile: String?
    
    init() {
        name = "홍길동"
        profile = nil
    }
    
    init(_ name: String) {
        self.name = name
        profile = nil
    }
    
    func toString() -> String {
        return "[name: " + name + ", profile: " + "dd" + "]"
    }
}
