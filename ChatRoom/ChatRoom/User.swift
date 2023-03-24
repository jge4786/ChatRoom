import UIKit

struct User: Codable {
    let name: String
    let profile: String?
    let uid: Int
    
    init() {
        name = "홍길동"
        profile = nil
        uid = 0
    }
    
    init(_ name: String, _ uid: Int) {
        self.name = name
        profile = nil
        self.uid = uid
    }
    
    func toString() -> String {
        return "[name: " + name + ", profile: " + "dd" + "]"
    }
}
