

class ChatData {
    private var users: [User] = [
        User("하나"),
        User("둘"),
        User("셋"),
        User("넷"),
        User("다섯"),
    ]
    
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
    }
    
    /// limit으로 0 입력 시, 전체 리스트 반환
    public func getUserList(offset: Int = 0, limit: Int = 0) -> [User] {
        if limit == 0 { return users }
        
        return Array(users[offset..<(offset+limit)])
    }
}
