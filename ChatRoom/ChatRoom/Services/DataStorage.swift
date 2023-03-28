import Foundation

class DataStorage {
    public static let instance = DataStorage()
    
    private let userDataKey = "userList"
    private let chatDataKey = "chatList"
    private let chatRoomDataKey = "chatRoomList"
    
    private var userList: [User] = []
    private var chatList: [Int : [Chat]] = [:] // [ roomId : [Chat] ]
    private var chatRoomList: [ChatRoom] = []
    
    private var cursor = -1
    
    private var chatIndex: Int {
        get {
            cursor += 1
            
            return cursor
        } set {
            cursor = newValue
        }
    }
    
    private init() {
        initialize()
    }
    
    private func initialize() {
        userList = [
            User("하나", 0, profile: "defaultImage1"),
            User("둘", 1, profile: "defaultImage2"),
            User("셋", 2, profile: "defaultImage3"),
            User("넷", 3, profile: "defaultImage4"),
            User("다섯", 4, profile: "defaultImage5"),
            User("나", 5, profile: "defaultImage5"),
        ]
        
        chatList = [
            0 : [Chat(roomId:0, chatId: chatIndex, owner: userList[0], sentDateTime: "2023-01-01 12:30", text: "hello")]
        ]
        
        chatRoomList = [
            ChatRoom(0, "채팅방1", userList)
        ]
    }
}

/**
 채팅방
 */
extension DataStorage {
    public func getChatRoomList() -> [ChatRoom] {
        return chatRoomList
    }
    
    public func getChatRoom(roomId: Int) -> ChatRoom? {
        return chatRoomList.first {
            $0.roomId == roomId
        }
    }
}

/**
 사용자
 */
extension DataStorage {
    /// roomId로 -1 입력 시, 전체 사용자 목록 반환
    public func getUserList(roomId: Int = -1) -> [User] {
        if roomId == -1 { return userList }
        
        guard let result = getChatRoom(roomId: roomId) else { return [] }
        
        return result.userList
    }
    
    public func getUser(userId: Int) -> User? {
        return userList.first {
            $0.userId == userId
        }
    }
}

/**
 채팅 목록
 */
extension DataStorage {
    private func now() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: Date())
    }
    
    /// limit으로 0 입력 시, 해당 채팅방의 전체 채팅 반환
    public func getChatData(roomId: Int, offset: Int = 0, limit: Int = 0) -> [Chat] {
        guard let result: [Chat] = chatList[roomId] else { return [] }
        
        if limit == 0 { return result }
        
        return Array(result[offset..<(offset+limit)])
    }
    
    public func appendChatData(roomId: Int, data: Chat) -> Chat {
        if chatList[roomId] != nil {
            chatList[roomId]!.append(data)
        } else {
            chatList[roomId] = [data]
        }
        
        saveChatData()
        
        return data
    }
    
    public func appendChatData(roomId: Int, owner: User, text: String) -> Chat {
        return appendChatData(roomId: roomId, data: Chat(roomId: roomId, chatId: chatIndex, owner: owner, sentDateTime: now(), text: text, unreadCount: 0))
    }
    
    public func appendChatData(roomId: Int, owner: User, image: Data) -> Chat {
        return appendChatData(roomId: roomId, data: Chat(roomId: roomId, chatId: chatIndex, owner: owner, sentDateTime: now(), unreadCount: 0, image: image))
    }
    
}

/**
 데이터 저장 / 불러오기
 */
extension DataStorage {
    // 데이터 초기화
    public func flushChatData() {
        initialize()
        
        saveData()
    }
    
    public func saveChatData() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatList), forKey: chatDataKey)
    }
    
    // 데이터 저장
    public func saveData() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.userList), forKey: userDataKey)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatList), forKey: chatDataKey)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatRoomList), forKey: chatRoomDataKey)
    }
    
    // 데이터 불러오기
    public func loadData() {
        guard let chatListData = UserDefaults.standard.value(forKey: chatDataKey) as? Data,
              let userListData = UserDefaults.standard.value(forKey: userDataKey) as? Data,
              let chatRoomListData = UserDefaults.standard.value(forKey: chatRoomDataKey) as? Data
        else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatList), forKey: chatDataKey)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.userList), forKey: userDataKey)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatRoomList), forKey: chatRoomDataKey)
            
            initialize()
            
            return
        }
        
        guard let loadedChatData = try? PropertyListDecoder().decode([Int : [Chat]].self, from: chatListData),
              let loadedUserData = try? PropertyListDecoder().decode([User].self, from: userListData),
              let loadedChatRoomData = try? PropertyListDecoder().decode([ChatRoom].self, from: chatRoomListData)
        else {
            fatalError("데이터 로딩 중 에러")
            return
        }
        
        chatList = loadedChatData
        userList = loadedUserData
        chatRoomList = loadedChatRoomData
    }
}