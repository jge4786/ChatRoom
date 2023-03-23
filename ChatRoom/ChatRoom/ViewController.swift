//
//  ViewController.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/22.
//

import UIKit

class ViewController: UIViewController {
    let me = User("나")
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var searchButton: EmptyTextButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var inputTextViewWrapper: UIView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    
    var textInputReturnCount = 0
    
    let textInputDefaultInset = 6.0
    
    var chatSectionData: [[Chat]] = []
    
    var chatData: [Chat] = [] {
        willSet {
            if chatData.count > newValue.count {
                print("줄었음")
            }else {
                guard let newChat: Chat = newValue.last else { return }
                storage.appendChatData(data: newChat)
//                calculateSection(data: newChat)
            }
        }
        didSet {
            contentTableView.reloadData()
//            scrollToBottom()
            
            
//            var it = 0, it_ = 0
//            for dt in chatSectionData {
//                for dt_ in dt {
//                    print(it, it_, dt_.toString())
//                    it_ += 1
//                }
//                it += 1
//            }
            
            print("----------------------------------")
        }
    }
    
    private func calculateSection(data: Chat) {
        calculateSection(data: [data])
    }
    
    private func calculateSection(data: [Chat]) {
        var lastMessageDate = chatSectionData.last?.last?.sentDate ?? "1800-01-01"
        
        print("chatData", chatData.count)
        
        data.map() {
            print(lastMessageDate, $0.sentDate)
            if $0.sentDate != lastMessageDate {
                chatSectionData.append([])
                lastMessageDate = $0.sentDate
            }

            chatSectionData[chatSectionData.count - 1].append($0)
        }
        
       
    }
    
    let storage = ChatData()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //데이터 초기화
        chatData = storage.getChatData(offset: 0, limit: 0)
        
        //디바이스 크기 저장
        Constants.deviceSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        //키보드 관련 등록
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        self.inputTextView.delegate = self
        
        //버튼 텍스트 제거
        addImageButton.setTitle("", for: .normal)
        sendMessageButton.setTitle("", for: .normal)
        
        //UI 초기화
        inputTextViewHeight.constant = getTextViewHeight()
        
        initHeaderButtonsSetting()
        initTextView()
        
        //테이블 뷰 셀 등록
        ChatTableViewCell.register(tableView: contentTableView)
        
        
        //디버그용
//        appendChat(data: Chat(owner: User("넷"), sentDateTime: "2021-04-10 23:00", text: "wowowow"
//                             ))
    }
    
    
    // 빈 메세지 확인
    func isMessageEmpty() -> Bool {
        guard let text = inputTextView.text else{ return true }
        return text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // 전송 버튼 눌림
    @IBAction func onPressSendMessageButton(_ sender: Any) {
        if isMessageEmpty() { return }
        
        let text = inputTextView.text
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let sendTime = formatter.string(from: Date())
        
        appendChat(data: Chat(owner: me, sentDateTime: sendTime, text: text!, unreadCount: storage.getUserList().count - 1))
        
        inputTextView.text = ""
        sendMessageButton.setImage(UIImage(systemName: "moon"), for: .normal)
    }
    
    

}

// 입력창
extension ViewController {
    func initTextView() {
        inputTextViewWrapper.layer.cornerRadius = 15
        inputTextViewWrapper.layer.borderWidth = 1
        inputTextViewWrapper.layer.borderColor = Color.DarkerGray
    }
    
    func appendChat(data: Chat) {
        chatData.append(data)
    }
}

// 헤더
extension ViewController {
    func initHeaderButtonsSetting() {
        searchButton.setTitle("", for: .normal)
        searchButton.tintColor = UIColor(cgColor: Color.White)
        
        menuButton.setTitle("", for: .normal)
        menuButton.tintColor = UIColor(cgColor: Color.White)
        
        goBackButton.setTitle(String(storage.getUserList(offset: 0, limit: 0).count), for: .normal)
        goBackButton.tintColor = UIColor(cgColor: Color.White)
    }
}


// 키보드
extension ViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardWillShowAndHide),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardWillShowAndHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    @objc func keyBoardWillShowAndHide(notification: NSNotification) {
        let userInfo = notification.userInfo
        guard let endValue = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
        guard let durationValue = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] else { return }
        
        guard let keyboardHeight = (endValue as? CGRect)?.size.height else { return }
                
        let duration = (durationValue as AnyObject).doubleValue
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            contentWrapperView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            contentTableView.contentInset.top = keyboardHeight
        case UIResponder.keyboardWillHideNotification:
            contentWrapperView.transform = .identity
            contentTableView.contentInset.top = 0
        default:
            break
        }
    }
    
}


//테이블 뷰 초기화
extension ViewController:  UITableViewDataSource, UITableViewDelegate{
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatData.count - 1, section: 0)
            
            self.contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard case let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
            return UITableViewCell()
        }

        cell.setData(chatData[indexPath.row])
        return cell
    }
}

extension UIViewController {
    func recognizeHidingKeyboardGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer (
            target: self, action: #selector(UIViewController.dissmissKeyboard)
            )
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController: UITextViewDelegate {
    func getTextViewHeight() -> Double {
        return inputTextView.getTextViewSize().height
    }

    public func setTextViewHeight() {
        guard inputTextView.numberOfLines() <= 5 else { return }
        
        inputTextViewHeight.constant = getTextViewHeight()
    }
    
    func setSendMessageButtonImage(isEmpty: Bool) {
        sendMessageButton.setImage(UIImage(systemName: isEmpty ? "moon" : "paperplane"), for: .normal)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        setTextViewHeight()
        setSendMessageButtonImage(isEmpty: textView.text.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

extension UITextView {
    func getTextViewSize() -> CGSize {
        let size = CGSize(width: self.frame.width, height: .infinity)
        
        let estimatedSize = self.sizeThatFits(size)
        
        return estimatedSize
    }
    
    func getTextViewHeight(limit: Int = 0) -> (Double, Bool) {
        guard self.numberOfLines() > 0 && self.numberOfLines() <= limit else {
            return (Double(self.font!.lineHeight) * Double(limit), false)
        }
        
        return (self.getTextViewSize().height, true)
    }
        
    func numberOfLines() -> Int {
        let size = getTextViewSize()
        
        return Int(size.height / self.font!.lineHeight)
    }
}
