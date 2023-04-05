import Foundation

final class DataStorage {
    public static let instance = DataStorage()
    
    private let userDataKey = "userList"
    private let chatDataKey = "chatList"
    private let chatRoomDataKey = "chatRoomList"
    private let chatGptKey = "chatGptList"
    private let gptRoomKey = "GPT"
    
    private var userList: [User] = []
    private var chatList: [Chat] = []
    private var chatRoomList: [ChatRoom] = []
    private var gptChatList: [Int : [Message]] = [:] // messageSetId : Message
    
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
    func getChatRoomList() -> [ChatRoom] {
        return chatRoomList
    }
    
    func getChatRoom(roomId: Int) -> ChatRoom? {
        return chatRoomList.first {
            $0.roomId == roomId
        }
    }
    
    func getGPTRoom() -> Int {
        let result = chatRoomList.first { $0.roomName == gptRoomKey }
        
        guard let result = result else { return makeChatGPTRoom().roomId }
        
        print("리절트.룸아이디 \(result.roomId)")
        
        return result.roomId
    }
    
    @discardableResult
    func makeChatRoom(name: String) -> ChatRoom {
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
    func makeChatGPTRoom() -> ChatRoom {
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
    
    func isGPTRoom(roomId: Int) -> Bool {
        return roomId == gptRoomId
    }
    
//    public func makeChatRoom(roomId: Int, userId: Int...) { }
}

/**
 사용자
 */
extension DataStorage {
    /// roomId로 -1 입력 시, 전체 사용자 목록 반환
    func getUserList(roomId: Int = -1) -> [User] {
        if roomId == -1 { return userList }
        
        guard let result = getChatRoom(roomId: roomId) else { return [] }
        
        return result.userList
    }
    
    func getUser(userId: Int) -> User? {
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
    func getChatData(roomId: Int, offset: Int = 0, limit: Int = 0) -> [Chat] {
        
        let result = chatList.filter {
            print("비교", $0.roomId, roomId)
            return $0.roomId == roomId
            
        }
        
        print("GETCHATDATA!!!!")
        
        guard result.count > 0 else { return [] }
        
        print("전체 데이터: ", result.count, offset, limit)
        
        let endIndex =
            offset + limit > result.count
            ? (result.count - 1)
            : (offset + limit)
        
        if limit == 0 { return result }
        
        print("endIndex: \(endIndex)")
        
        return Array(result.reversed()[offset..<endIndex])
    }
    
    func getChat(chatId: Int) -> Chat? {
        guard let result = chatList.first(where: { $0.chatId == chatId }) else { return nil }
        
        return result
    }
    
    func appendChatData(roomId: Int, data: Chat) -> Chat {
        if chatList.isEmpty {
            chatList = [data]
        } else {
            chatList.append(data)
        }
        
        saveChatData()
        
        return data
    }
    
    func appendChatData(roomId: Int, owner: User, text: String) -> Chat {
        return appendChatData(roomId: roomId, data: Chat(roomId: roomId, chatId: chatIndex, owner: owner, sentDateTime: now(), text: text, unreadCount: 0))
    }
    
    func appendChatData(roomId: Int, owner: User, image: Data) -> Chat {
        return appendChatData(roomId: roomId, data: Chat(roomId: roomId, chatId: chatIndex, owner: owner, sentDateTime: now(), unreadCount: 0, image: image))
    }
    
    func deleteChatData(roomId: Int) {
        chatList.removeAll {
            $0.roomId == roomId
        }
        
        saveChatData()
    }
}


///GPT
extension DataStorage {
    func getGptDataSet(dataSetId id: Int) -> [Message]? {
        guard let result = gptChatList[id] else { return nil }
        
        return result
    }
    /// 챗GPT 데이터 입력
    func appendGptChatData(dataSetId id: Int, message: Message) -> Message {
        if gptChatList[id] == nil {
            gptChatList[id] = [message]
        } else {
            gptChatList[id]?.append(message)
        }
        
        saveData()
        
        return message
    }
    
    /// 챗GPT 대화 세트 중 지정된 세트 하나 삭제
    func deleteGptChatData(dataSetId id: Int) {
        let index =  gptChatList.firstIndex { $0.key == id }

        print(index)
        guard let index = index else { return }
        
        gptChatList.remove(at: index)
        
        saveData()
    }
    
    
    /// 챗GPT 대화 세트 전체 삭제
    func clearGptChatData() {
        gptChatList = [:]
        
        saveData()
    }
}

/**
 데이터 저장 / 불러오기
 */
extension DataStorage {
    // 데이터 초기화
    func flushChatData() {
        initialize()
        
        saveData()
    }
        
    func saveChatData() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatList), forKey: chatDataKey)
    }
    
    // 데이터 저장
    func saveData() {
        print("dddd")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.userList), forKey: userDataKey)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatList), forKey: chatDataKey)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatRoomList), forKey: chatRoomDataKey)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.gptChatList), forKey: chatGptKey)
    }
    
    // 데이터 불러오기
    func loadData() {
        guard let chatListData = UserDefaults.standard.value(forKey: chatDataKey) as? Data,
              let userListData = UserDefaults.standard.value(forKey: userDataKey) as? Data,
              let chatRoomListData = UserDefaults.standard.value(forKey: chatRoomDataKey) as? Data,
                let gptChatListData = UserDefaults.standard.value(forKey: chatGptKey) as? Data
        else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatList), forKey: chatDataKey)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.userList), forKey: userDataKey)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatRoomList), forKey: chatRoomDataKey)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.gptChatList), forKey: chatGptKey)
            
            print("error - loadDataFromUserDefaults")
            initialize()
            saveData()
            
            return
        }
        
        guard let loadedChatData = try? PropertyListDecoder().decode([Chat].self, from: chatListData),
              let loadedUserData = try? PropertyListDecoder().decode([User].self, from: userListData),
              let loadedChatRoomData = try? PropertyListDecoder().decode([ChatRoom].self, from: chatRoomListData),
              let loadedGptChatData = try? PropertyListDecoder().decode([Int : [Message]].self, from: gptChatListData)
        else {
            print("데이터 로딩 중 에러. 데이터 초기화 필요")
            return
        }
        
        chatList = loadedChatData
        
        
        chatIndex = chatList.last?.chatId ?? -1

        userList = loadedUserData
        
        chatRoomList = loadedChatRoomData
        
        gptRoomId = chatRoomList.first { $0.roomName == gptRoomKey }?.roomId
        
        gptChatList = loadedGptChatData
        
        flushChatData()
    }
    

    enum DataError {
        case loadFromUserDefaultsFailure
        case dataDecodeFailure
    }
}
