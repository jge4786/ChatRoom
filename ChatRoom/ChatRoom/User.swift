import UIKit

class User {
    let name: String
    let profile: UIImage?
    
    init() {
        name = "홍길동"
        profile = nil
    }
    
    init(_ name: String) {
        self.name = name
        profile = nil
    }
}
