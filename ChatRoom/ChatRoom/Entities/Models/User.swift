struct User: Codable {
    let name: String
    let profile: String?
    let userId: Int
    
    init() {
        name = "홍길동"
        profile = nil
        userId = 0
    }
    
    init(_ name: String, _ userId: Int, profile: String? = nil) {
        self.name = name
        self.profile = profile
        self.userId = userId
    }
    
    func toString() -> String {
        return "[name:  \(name), profile: \(profile ?? "none")]"
    }
}
