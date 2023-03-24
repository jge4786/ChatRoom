import Foundation

class ChatData {
    private var users: [User] = [
        User("하나"),
        User("둘"),
        User("셋"),
        User("넷"),
        User("다섯"),
    ]
    
//    @UserDefaultWrapper(key: "chatData", defaultValue: nil)
    private var chatData: [Chat]
    
    init() {
        chatData = [
            Chat(owner: users[0], sentDateTime: "2023-01-01 04:11", text: "테스트 텍스트", unreadCount: 1),
            Chat(owner: users[2], sentDateTime: "2023-01-01 15:05", text: "테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 테스트 텍스트 "),
            Chat(owner: users[1], sentDateTime: "2023-04-01 06:30", text: "텍스트\n테스트\nTest\n테스스스스\n테세세세텟테세\n\n\n\n\n\nㅇㅁㄴㅇㄹ", unreadCount: 3),
        ]
    }
    
    /// limit으로 0 입력 시, 전체 리스트 반환
    public func getChatData(offset: Int = 0, limit: Int = 0) -> [Chat] {
        
        if limit == 0 { return chatData }
        
        return Array(chatData[offset..<(offset+limit)])
    }
    
    public func appendChatData(data: Chat) {
        chatData.append(data)
        saveData()
    }
    
    /// limit으로 0 입력 시, 전체 리스트 반환
    public func getUserList(offset: Int = 0, limit: Int = 0) -> [User] {
        if limit == 0 { return users }
        
        return Array(users[offset..<(offset+limit)])
    }
    
    public func flushChatData() {
        chatData = []
        
        saveData()
    }
    
    public func saveData() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.chatData), forKey: "chatData")
        
        print(chatData)
//        UserDefaults.standard.set(chatData, forKey: "chatData")
    }
    
    public func loadData() {
        let tmp1 = Chat(), tmp2 = User()
        
        guard let data = UserDefaults.standard.value(forKey: "chatData") as? Data else { return }
        
        guard let loadedData = try? PropertyListDecoder().decode([Chat].self, from: data) else { return  }
        
        chatData = loadedData
        
//        guard let loadedData: [Chat] = UserDefaults.standard.array(forKey: "chatData") as? [Chat] else {
//            chatData = []
//
//            return
//        }
        
//        chatData = loadedData
    }
}


@propertyWrapper
struct UserDefaultWrapper<T: Codable> {
    private let key: String
    private let defaultValue: T?
    
    init(key: String, defaultValue: T?) {
        self.key = key
        self.defaultValue = defaultValue
    }
        
    var wrappedValue: T? {
        get{
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let loadedObject = try? decoder.decode(T.self, from: savedData) {
                    print(loadedObject)
                    return loadedObject
                }
            }
            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            print("dd?")
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encoded, forKey: key)
            }
        }
    }
}
