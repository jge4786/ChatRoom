import UIKit

extension ChatRoomViewController {
    func isMessageEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func sendMessage(owner: User, text: String?, isUser: Bool = true) {
        if isMessageEmpty(text) { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        chatData.insert( DataStorage.instance.appendChatData(roomId: roomId, owner: owner, text: text!), at: 0)
        
        // 챗GPT가 작성한 채팅일 경우
        guard isUser else {
            contentTableView.reloadData()
            scrollToBottom()
            return
            
        }
        
        inputTextView.text = ""
        inputTextViewHeight.constant = getTextViewHeight()
        
        textViewLine = 1
        
        letterCountWrapperView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5.0, right: 10.0)
        letterCountWrapperView.isHidden = true
        
        contentTableView.reloadData()
        scrollToBottom()
        
        sendMessageButton.setImage(nil, for: .normal)
        sendMessageButton.setTitle("#", for: .normal)
        sendMessageButton.tintColor = Color.LighterBlack
    }
    
    // 챗GPT의 메세지 업데이트
    func updateLatestMessage(text: String) {
        guard let firstIndex = chatData.first?.chatId else { return }
        _ = DataStorage.instance.updateChatData(roomId: roomId, chatId: firstIndex, text: text)
        
        guard chatData.first != nil else { return }
        chatData[0].text = text
    }
    
    //일반 채팅방에서 대화할 경우 사용
    func sendMessage() {
        sendMessage(owner: userData, text: inputTextView.text)
        contentTableView.reloadData()
    }
    
    //챗GPT 채팅방에서 대화할 경우 사용
    func sendMessageToGPT() {
        let text = inputTextView.text
        if isMessageEmpty(text) { return }

        guard let text = text else { return }
        
        sendMessage()
        
        var gptDataSet = DataStorage.instance.getGptDataSet(dataSetId: roomId)
        
        if gptDataSet == nil {
            gptDataSet = []
        }
        
        let requestedMessage = Message(role: "user", content: text)
        
        gptDataSet?.append( DataStorage.instance.appendGptChatData(dataSetId: roomId, message: requestedMessage) )
        
        guard let gptDataSet = gptDataSet else { return }
        
        sendMessage(owner: self.gptInfo!, text: "...", isUser: false)
        
        sendMessageButton.isHidden = true
        messageLoadingIndicator.startAnimating()
        dataTask = APIService.shared.sendChat(text: gptDataSet) { [weak self] response in
            guard let self = self else { return }
            _ = DataStorage.instance.appendGptChatData(dataSetId: self.roomId, message: response)
            self.updateLatestMessage(text: response.content)
            self.sendMessageButton.isHidden = false
            self.messageLoadingIndicator.stopAnimating()
        }
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    func getTextViewHeight() -> Double {
        return inputTextView.getTextViewSize().height
    }

    public func setTextViewHeight() {
        let lines = inputTextView.numberOfLines()
        guard lines <= 5 else { return }
        
        textViewLine = lines
        
        inputTextViewHeight.constant = getTextViewHeight()
    }
    
    func setSendMessageButtonImage(isEmpty: Bool) {
        
        
        if isEmpty {
            sendMessageButton.setImage(nil, for: .normal)
            sendMessageButton.setTitle("#", for: .normal)
            sendMessageButton.tintColor = Color.LighterBlack
        } else {
            sendMessageButton.setTitle("", for: .normal)
            sendMessageButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
            sendMessageButton.tintColor = Color.Yellow
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        // 글자 수 제한
        guard textView.text.count <= Constants.inputLimit else {
            textView.text = String(textView.text.prefix(Constants.inputLimit))
            
            return
        }
        
        setTextViewHeight()
        
        setSendMessageButtonImage(isEmpty: textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        
        if !textView.text.isEmpty {
            letterCountWrapperView.isHidden = false
            letterCountLabel.text = "\(textView.text.count) / \(Constants.inputLimit)"
        } else {
            letterCountWrapperView.isHidden = true
        }
    }
}
