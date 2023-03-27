import UIKit

class ViewController: UIViewController {
    let me = 5
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var searchButton: EmptyTextButton!   // 대화 검색 버튼
    @IBOutlet weak var menuButton: UIButton!            // 서랍 열기 버튼
    @IBOutlet weak var goBackButton: UIButton!          // 대화창 나가기 버튼 (뒤로가기)
    
    @IBOutlet weak var footerWrapperView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!     // 메세지 전송 버튼
    @IBOutlet weak var inputTextViewWrapper: UIView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!        // 이미지 첨부 버튼
    
    @IBOutlet weak var letterCountWrapperView: UIView!
    @IBOutlet weak var letterCountLabel: UILabel!
    @IBOutlet weak var letterCountButton: UIButton!     // 글자 수 계산 (라벨 대용)
    @IBOutlet weak var scrollToBottomButton: UIButton!  // 가장 밑으로 스크롤
    
    @IBOutlet weak var tmpWrapperView: UIView!
    var textViewLine = 1 {
        didSet {
            if oldValue == textViewLine {
//                print("lineTest: 같")
            }else{
                guard let lineHeight = inputTextView.font?.lineHeight else { return }
                
                let direction: Double = Double(textViewLine - oldValue)
                let translationValue = lineHeight * direction
                
                contentTableView.contentOffset.y = contentTableView.contentOffset.y + translationValue
            }
        }
    }
    
    var textInputReturnCount = 0
    
    let textInputDefaultInset = 6.0
    var safeAreaBottomInset: CGFloat = 0.0
    
    var chatSectionData: [[Chat]] = []
    
    var isInitialLoad = true
    
    var chatData: [Chat] = [] {
        willSet {
            if chatData.count > newValue.count {
//                print("줄었음")
            }else {
                guard let newChat: Chat = newValue.last else { return }
                guard !isInitialLoad else { isInitialLoad = false; return; }
                storage.appendChatData(data: newChat)
                calculateSection(data: newChat)
            }
        }
        didSet {
            contentTableView.reloadData()
            scrollToBottom()
        }
    }
    
    private func calculateSection(data: Chat) {
        calculateSection(data: [data])
    }
    
    private func calculateSection(data: [Chat]) {
        var lastMessageDate = chatSectionData.last?.last?.sentDate ?? "1800-01-01"
        
        data.map() {
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
        
        storage.loadData()
        
        //데이터 초기화
        chatData = storage.getChatData(offset: 0, limit: 0)
                
        //키보드 관련 등록
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        self.inputTextView.delegate = self
        self.contentTableView.delegate = self
        
        //버튼 텍스트 제거
        addImageButton.setTitle("", for: .normal)
        sendMessageButton.setTitle("", for: .normal)
        scrollToBottomButton.setTitle("", for: .normal)
        
        scrollToBottomButton.tintColor = UIColor(cgColor: Color.LighterBlack)
        
        //UI 초기화
        inputTextViewHeight.constant = getTextViewHeight()
        letterCountWrapperView.layer.cornerRadius = 8
        
        initHeaderButtonsSetting()
        initTextView()
        
        //테이블 뷰 셀 등록
        ChatTableViewCell.register(tableView: contentTableView)
        MyChatCell.register(tableView: contentTableView)
        
        
        
        safeAreaBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        //디버그용
    }
    
    deinit{
//        storage.flushChatData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //하단 버튼의 위치를 고정하기 위한 높이 조절
        NSLayoutConstraint.activate([
            addImageButton.heightAnchor.constraint(equalToConstant: footerWrapperView.frame.height),
            sendMessageButton.heightAnchor.constraint(equalToConstant: inputTextViewWrapper.frame.height)
        ])
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
        
        appendChat(data: Chat(owner: storage.getUser(uid: me), sentDateTime: sendTime, text: text!, unreadCount: storage.getUserList().count - 1))
        
        inputTextView.text = ""
        inputTextViewHeight.constant = getTextViewHeight()
        
        textViewLine = 1
        
        letterCountWrapperView.isHidden = true
        
        sendMessageButton.setImage(UIImage(systemName: "moon"), for: .normal)
    }
    @IBAction func onPressScrollToBottom(_ sender: Any) {
        scrollToBottom()
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
        
        guard let keyboardHeight = (endValue as? CGRect)?.size.height else { return }
        
        let translationValue = keyboardHeight - safeAreaBottomInset
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            contentWrapperView.transform = CGAffineTransform(translationX: 0, y: -translationValue)
            contentTableView.contentInset.top = translationValue
            contentTableView.verticalScrollIndicatorInsets = UIEdgeInsets(
                top: translationValue,
                left: 0, bottom: 0, right: 0
            )
        case UIResponder.keyboardWillHideNotification:
            contentWrapperView.transform = .identity
            contentTableView.contentInset.top = 0
            contentTableView.verticalScrollIndicatorInsets = .zero
        default:
            break
        }
    }
    
}


//테이블 뷰 초기화
extension ViewController:  UITableViewDataSource, UITableViewDelegate{
    
    
    func scrollToBottom() {
        guard self.chatData.count > 0 else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatData.count - 1, section: 0)
            
            self.contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uid = chatData[indexPath.row].owner.uid
        
        if uid != me {
            guard case let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
                return UITableViewCell()
            }
            
            cell.setData(chatData[indexPath.row])
            
            return cell
        }else{
            guard case let cell = MyChatCell.dequeueReusableCell(tableView: contentTableView) else {
                return UITableViewCell()
            }
            
            cell.setData(chatData[indexPath.row])
            return cell
        }

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
        let lines = inputTextView.numberOfLines()
        guard lines <= 5 else { return }
        
        textViewLine = lines
        
        inputTextViewHeight.constant = getTextViewHeight()
    }
    
    func setSendMessageButtonImage(isEmpty: Bool) {
        sendMessageButton.setImage(UIImage(systemName: isEmpty ? "moon" : "paperplane"), for: .normal)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        setTextViewHeight()
        
        setSendMessageButtonImage(isEmpty: textView.text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines).isEmpty)
        
        if !textView.text.isEmpty {
            letterCountWrapperView.isHidden = false
            letterCountLabel.text = "\(textView.text.count) / 1000"
//            letterCountButton.isHidden = false
//            letterCountButton.setTitle("\(trimmedText.count)/1000", for: .normal)
        }else {
            letterCountWrapperView.isHidden = true
//            letterCountButton.isHidden = true
        }
    }
}

extension UITextView {
    func getTextViewSize(gap: CGFloat = 0 ) -> CGSize {
        let size = CGSize(width: (Constants.deviceSize.width - gap) * Constants.chatMaxWidthMultiplier, height: .infinity)
        
        let estimatedSize = self.sizeThatFits(size)
        
        
        return estimatedSize
    }
    
    func getTextViewHeight(limit: Int = 0, gap: CGFloat = 0) -> (Double, Bool) {
        guard self.numberOfLines(gap: gap) > 0 && self.numberOfLines(gap: gap) <= limit + 1 else {
            return (Double(self.font!.lineHeight) * Double(limit + 1), false)
        }
        
        return (self.getTextViewSize(gap: gap).height, true)
    }
        
    func numberOfLines(gap: CGFloat = 0) -> Int {
        let size = getTextViewSize(gap: gap)
        
        return Int(size.height / self.font!.lineHeight)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    // 스크롤 버튼 표시 관리
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        let offsetValue = scrollView.contentSize.height - (scrollView.bounds.size.height + scrollView.contentOffset.y)
        
//        print(scrollView.contentSize.height, scrollView.bounds.size.height, scrollView.contentOffset.y)
        
//        print(velocity, offsetValue, scrollToBottomButton.isHidden)
        
        if velocity >= 0 && offsetValue > Constants.deviceSize.height && scrollToBottomButton.isHidden {
//            NSLayoutConstraint.activate([
//                scrollToBottomButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
//            ])
            scrollToBottomButton.isHidden = false
        }else if velocity <= 0 && offsetValue < 10 && !scrollToBottomButton.isHidden {
//            NSLayoutConstraint.deactivate([
//                scrollToBottomButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
//            ])
            scrollToBottomButton.isHidden = true
        }
    }
}
