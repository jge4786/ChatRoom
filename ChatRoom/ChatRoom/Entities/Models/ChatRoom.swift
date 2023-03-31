struct ChatRoom: Codable {
    let roomId: Int
    let roomName: String
    var userList: [User]
    
    init() {
        roomId = 0
        roomName = "빈 방"
        userList = []
    }
    
    init(_ roomId: Int, _ roomName: String, _ userList: [User]) {
        self.roomId = roomId
        self.roomName = roomName
        self.userList = userList
    }
}
