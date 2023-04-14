///1. 데이터 초기화 -> 데이터
///2. 버튼 터치
///3. 버튼 눌렸을 때
///4. 데이터 로딩 준비

class ChatCellViewModel {
    var chatId: Observable<Int> = Observable(-1)
    var chat: Observable<Chat?> = Observable(nil)
    func setData(data: Chat) {
        chat.value = data
        
        chatId.value = data.chatId
    }
}
