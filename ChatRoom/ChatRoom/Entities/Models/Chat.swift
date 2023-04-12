import Foundation

struct Chat: Codable {
    let roomId: Int
    var chatId: Int
    let owner: User
    let sentDateTime: String
    var unreadCount: Int
    var text: String
    let image: Data
    
    var sentDate: String {
        get {
            String(sentDateTime.split(separator: " ").first ?? "--")
        }
    }
    
    var sentTime: String {
        get {
            String(sentDateTime.split(separator: " ").last ?? "--")
        }
    }
    
    init() {
        self.roomId = 0
        self.chatId = 0
        self.owner = User()
        self.sentDateTime = "1900-01-01 00:01"
        self.unreadCount = 0
        self.text = ""
        self.image = Data()
    }
    
    init(roomId: Int, chatId: Int, owner: User, sentDateTime: String, text: String = "", unreadCount: Int = 0, image: Data = Data()) {
        self.owner = owner
        self.sentDateTime = sentDateTime
        self.unreadCount = unreadCount
        self.text = text
        self.image = image
        self.roomId = roomId
        self.chatId = chatId
    }
    
    func toString() -> String {
        return "[chatId: " + String(chatId) + ", owner: " + owner.toString() + ", sentDateTime: " + sentDateTime + ", unreadCount: " + String(unreadCount) + "]"
    }
}
