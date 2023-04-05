import Foundation

final class DataStorage {
    public static let instance = DataStorage()
    
    private let userDataKey = "userList"
    private let chatDataKey = "chatList"
    private let chatRoomDataKey = "chatRoomList"
    private let gptRoomKey = "GPT"
    
    private var userList: [User] = []
    private var chatList: [Chat] = []
    private var chatRoomList: [ChatRoom] = []
    
    private var gptRoomId: Int?
    
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
        loadData()
    }
    
    private func initialize() {
        userList = [
            User("GPT", 0),
            User("둘", 1, profile: "defaultImage2"),
            User("셋", 2, profile: "defaultImage3"),
            User("넷", 3, profile: "defaultImage4"),
            User("다섯", 4, profile: "defaultImage5"),
            User("나", 5, profile: "defaultImage5"),
        ]
        
        chatList = [Chat(roomId:0, chatId: chatIndex, owner: userList[0], sentDateTime: "2023-01-01 12:30", text: "hello")]
        
        chatRoomList = [
            ChatRoom(0, "채팅방1", userList),
            ChatRoom(1, "채팅방2", [
//                User("일", 0, profile: "defaultImage1"),
                User("이", 1, profile: "defaultImage2"),
                User("삼", 2, profile: "defaultImage3"),
                User("사", 3, profile: "defaultImage4"),
            ])
        ]
        
        makeChatGPTRoom()
//        loadData()
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
    
    public func getGPTRoom() -> Int {
        let result = chatRoomList.first { $0.roomName == gptRoomKey }
        
        guard let result = result else { return makeChatGPTRoom().roomId }
        
        print("리절트.룸아이디 \(result.roomId)")
        
        return result.roomId
    }
    
    @discardableResult
    public func makeChatRoom(name: String) -> ChatRoom {
        let newChatRoom = ChatRoom(chatRoomList.count, name,[
//            User("일", 0, profile: "defaultImage1"),
            User("이", 1, profile: "defaultImage2"),
            User("삼", 2, profile: "defaultImage3"),
            User("사", 3, profile: "defaultImage4"),
        ])
        
        chatRoomList.append(newChatRoom)
        
        return newChatRoom
    }
    
    //TODO: 테스트용으로 userId: 0으로 생성. 시간 나면 내 userId 지정하고 이 userId로 초기화하도록
    @discardableResult
    public func makeChatGPTRoom() -> ChatRoom {
        gptRoomId = chatRoomList.count
        let newChatRoom = ChatRoom(
            gptRoomId!,
            gptRoomKey,
            [
                getUser(userId: 1)!,
                getUser(userId: 0)!,
            ])
        
        chatRoomList.append(newChatRoom)
        
        return newChatRoom
    }
    
    public func isGPTRoom(roomId: Int) -> Bool {
        return roomId == gptRoomId
    }
    
//    public func makeChatRoom(roomId: Int, userId: Int...) { }
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
    
    ///sentTime에 저장할 현재 시간 받아오는 메소드
    private func now() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: Date())
    }
    
    /// limit으로 0 입력 시, 해당 채팅방의 전체 채팅 반환
    public func getChatData(roomId: Int, offset: Int = 0, limit: Int = 0) -> [Chat] {
        
        let result = chatList.filter {
            print("비교", $0.roomId, roomId)
            return $0.roomId == roomId
            
        }
        
        guard result.count > 0 else { return [] }
        
        print("전체 데이터: ", result.count, offset, limit)
        
        let endIndex =
            offset + limit > result.count
            ? (result.count - 1)
            : (offset + limit)
        
        if limit == 0 { return result }
        
        
        return Array(result.reversed()[offset..<endIndex])
    }
    
    public func getChat(chatId: Int) -> Chat? {
        guard let result = chatList.first(where: { $0.chatId == chatId }) else { return nil }
        
        return result
    }
    
    public func appendChatData(roomId: Int, data: Chat) -> Chat {
        if chatList.isEmpty {
            chatList = [data]
        } else {
            chatList.append(data)
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
    
    public func clearChatData(roomId: Int) {
        chatList.removeAll {
            $0.roomId == roomId
        }
        
        saveChatData()
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
        print("dddd")
        
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
            
            print("error - loadDataFromUserDefaults")
            initialize()
            
            return
        }
        
        guard let loadedChatData = try? PropertyListDecoder().decode([Chat].self, from: chatListData),
              let loadedUserData = try? PropertyListDecoder().decode([User].self, from: userListData),
              let loadedChatRoomData = try? PropertyListDecoder().decode([ChatRoom].self, from: chatRoomListData)
        else {
            print("데이터 로딩 중 에러. 데이터 초기화 필요")
            return
        }
        
        chatList = loadedChatData
        
        
        chatIndex = chatList.last?.chatId ?? -1

        userList = loadedUserData
        
        chatRoomList = loadedChatRoomData
        
        gptRoomId = chatRoomList.first { $0.roomName == gptRoomKey }?.roomId
        
        flushChatData()
    }
    

    enum DataError {
        case loadFromUserDefaultsFailure
        case dataDecodeFailure
    }
}
