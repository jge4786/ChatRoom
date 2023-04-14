import UIKit

extension ChatRoomViewController {
    func resetAfterSendingMessage(isUser: Bool) {
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
    
    func sendMessage(owner: User, text: String?, isUser: Bool = true) {
        chatViewModel.sendMessage(owner: owner, text: text!)
        
        resetAfterSendingMessage(isUser: isUser)
    }
    
    //일반 채팅방에서 대화할 경우 사용
    func sendMessage() {
        sendMessage(owner: userData, text: inputTextView.text)
        contentTableView.reloadData()
    }
    
    //챗GPT 채팅방에서 대화할 경우 사용
    func sendMessageToGPT() {
        chatViewModel.sendMessageToGPT(text: inputTextView.text)
        resetAfterSendingMessage(isUser: true)
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
