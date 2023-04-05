//
//  TextInputController.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/31.
//

import UIKit

extension ViewController {
    // 빈 메세지 확인
    func isMessageEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        
        return text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines).isEmpty
    }
    
    
    func sendMessage(owner: User, text: String?, isUser: Bool = true) {
        if isMessageEmpty(text) { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        chatData.insert( DataStorage.instance.appendChatData(roomId: roomId, owner: owner, text: text!), at: 0)
        
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
        sendMessageButton.tintColor = UIColor(cgColor: Color.LighterBlack)
    }
    
    func sendMessage() {
        sendMessage(owner: userList[selectedUser], text: inputTextView.text)
    }
    
    
    func sendMessageToGPT() {
        let text = inputTextView.text
        if isMessageEmpty(text) { return }

        guard let text = text else { return }
        
        sendMessage()
        
        var gptDataSet = DataStorage.instance.getGptDataSet(dataSetId: temporaryGptDataSetId)
        
        if gptDataSet == nil {
            gptDataSet = []
        }
        
        
        let requestedMessage = Message(role: "user", content: text)
        
        gptDataSet?.append( DataStorage.instance.appendGptChatData(dataSetId: temporaryGptDataSetId, message: requestedMessage) )
        
        guard let gptDataSet = gptDataSet else { return }
        
        APIService.shared.sendChat(text: gptDataSet) { response in
            self.sendMessage(owner: self.gptInfo!, text: response.content, isUser: false)
            self.gptMessageData.append(response)
        }
    }
}



extension ViewController: UITextViewDelegate {
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
            sendMessageButton.tintColor = UIColor(cgColor: Color.LighterBlack)
        } else {
            sendMessageButton.setTitle("", for: .normal)
            sendMessageButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
            sendMessageButton.tintColor = UIColor(cgColor: Color.Yellow)
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        // 글자 수 제한
        guard textView.text.count <= Constants.inputLimit else {
            textView.text = String(textView.text.prefix(Constants.inputLimit))
            
            return
        }
        
        setTextViewHeight()
        
        setSendMessageButtonImage(isEmpty: textView.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines).isEmpty)
        
        if !textView.text.isEmpty {
            letterCountWrapperView.isHidden = false
            letterCountLabel.text = "\(textView.text.count) / \(Constants.inputLimit)"
        }else {
            letterCountWrapperView.isHidden = true
        }
    }
}
