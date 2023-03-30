import UIKit
import PhotosUI

class ViewController: UIViewController {
    let storage = DataStorage.instance
    
    let me = 5
    let roomId = 0
    var selectedUser = 5
    
    var userData: User = User()
    var roomData: ChatRoom = ChatRoom()
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var goBackButton: UINavigationItem!
//    @IBOutlet weak var searchButton: UIButton!   // 대화 검색 버튼
//    @IBOutlet weak var menuButton: UIButton!            // 서랍 열기 버튼
//    @IBOutlet weak var goBackButton: UIButton!          // 대화창 나가기 버튼 (뒤로가기)
    
    @IBOutlet weak var footerWrapperView: UIView!
    @IBOutlet weak var sendMessageButton: UIButton!     // 메세지 전송 버튼
    @IBOutlet weak var inputTextViewWrapper: UIView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!        // 이미지 첨부 버튼
    
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var letterCountWrapperView: UIView!
    @IBOutlet weak var letterCountLabel: UILabel!
    @IBOutlet weak var scrollToBottomButton: UIButton!  // 가장 밑으로 스크롤
    
    @IBOutlet weak var dataLoadingScreen: UIView!
    @IBOutlet weak var tmpWrapperView: UIView!
    
    
    var isLoading = false
    
    // **************** 테스트용 ***************
    
    
    var userList: [User] = []
    
    @IBOutlet weak var selectUserButton: UIButton!
    
    func setSelectUserMenu() {
        var menuItems: [UIAction] = []
        
        for idx in 0..<userList.count {
            menuItems.append(
                UIAction(title: userList[idx].name, handler: { _ in self.selectUser(selected: idx) })
            )
        }
        
        selectUserButton.menu = UIMenu(title: "사용자 선택",
                                       identifier: nil,
                                       options: .displayInline,
                                       children: menuItems
        )
    }
    
    func selectUser(selected: Int) {
        selectedUser = selected
        selectUserButton.setTitle(userList[selected].name, for: .normal)
    }
    
    // ***************************************
    
    
    
    
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
    
    @IBAction func onPressEmojiButton(_ sender: Any) {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                inputTextView
            }
        }
    }
    @IBAction func onPressAddImageButton(_ sender: Any) {
//        present(imageController, animated: true)
        openPhotoLibrary()
    }
    var textInputReturnCount = 0
    
    let textInputDefaultInset = 6.0
    var safeAreaBottomInset: CGFloat = 0.0
    
        
    let imageController = UIImagePickerController()
    
    var isInitialLoad = true

    
    
    var chatData: [Chat] = [] {
        willSet {
            if chatData.count > newValue.count {
//                print("줄었음")
            }else {
                guard let newChat: Chat = newValue.last else { return }
                guard !isInitialLoad else { isInitialLoad = false; return; }
            }
        }
        didSet {
            contentTableView.reloadData()
        }
    }
        
    func fadeDataLoadingScreen() {
        UIView.animate(withDuration: 0.13, delay: 0.0, options: .curveEaseIn) {
            self.dataLoadingScreen.layer.opacity = 0
        } completion: { finished in
            self.dataLoadingScreen.isHidden = true
        }
    }
    
    var isEndReached = false
    var offset = 0
    func loadData() {
        let loadedData = DataStorage.instance.getChatData(roomId: roomId, offset: offset, limit: Constants.chatLoadLimit)
        chatData = loadedData + chatData
        
        print("챗데이터: ", loadedData.count)
        
        calcSectionData()
         
        // 로딩된 데이터가 제한보다 적으면 isEndReached을 true로 하여 로딩 메소드 호출 방지
        guard loadedData.count >= Constants.chatLoadLimit else {
            isEndReached = true
            return
        }
        
        offset += Constants.chatLoadLimit
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dataLoadingScreen.layer.zPosition = 100
        
        DataStorage.instance.loadData()
        guard let crData = DataStorage.instance.getChatRoom(roomId: roomId) else {
            fatalError("채팅방 정보 불러오기 실패")
        }
        roomData = crData
        
        guard let uData = DataStorage.instance.getUser(userId: me) else {
            fatalError("유저 정보 불러오기 실패")
        }
        userData = uData
        
        //데이터 초기화
        loadData()
                
        //키보드 관련 등록
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        self.inputTextView.delegate = self
        self.contentTableView.delegate = self
        
        //버튼 텍스트 제거
        addImageButton.setTitle("", for: .normal)
        scrollToBottomButton.setTitle("", for: .normal)
        emojiButton.setTitle("", for: .normal)
        searchButton.setTitle("", for: .normal)
        
        scrollToBottomButton.tintColor = UIColor(cgColor: Color.LighterBlack)
        
        //UI 초기화
        inputTextViewHeight.constant = getTextViewHeight()
        letterCountLabel.layer.cornerRadius = 8
        
        initHeaderButtonsSetting()
        initTextView()
        
        //테이블 뷰 셀 등록
        ChatTableViewCell.register(tableView: contentTableView)
        MyChatCell.register(tableView: contentTableView)
        
        
        //이미지 컨트롤러 등록
        imageController.sourceType = .photoLibrary
        imageController.delegate = self
        imageController.allowsEditing = true
        
        
        /// 첫번째 scrollToBottom: 데이터 로딩 및 UI 깨짐 방지
        /// 두번째 scrollToBottom: 스크롤 이동
        
        scrollToBottom() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.scrollToBottom() {
                    self.fadeDataLoadingScreen()
                }
            }
        }
        
        safeAreaBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        
        // ***************디버그, 테스트용*************
        
        userList = DataStorage.instance.getUserList()
        setSelectUserMenu()
        
        // ****************************************
    }
    
    deinit{
//        DataStorage.instance.flushChatData()
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
        return text.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines).isEmpty
    }
    
    // 전송 버튼 눌림
    @IBAction func onPressSendMessageButton(_ sender: Any) {
        if isMessageEmpty() { return }

        let text = inputTextView.text
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let sendTime = formatter.string(from: Date())
        
        chatData.append( DataStorage.instance.appendChatData(roomId: roomId, owner: userList[selectedUser], text: text!) )
        
        inputTextView.text = ""
        inputTextViewHeight.constant = getTextViewHeight()
        
        textViewLine = 1
        
        letterCountWrapperView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 5.0, right: 10.0)
        letterCountWrapperView.isHidden = true
        
        contentTableView.reloadData()
        scrollToBottom() {}
        
        sendMessageButton.setImage(nil, for: .normal)
        sendMessageButton.setTitle("#", for: .normal)
        sendMessageButton.tintColor = UIColor(cgColor: Color.LighterBlack)
    }
    @IBAction func onPressScrollToBottom(_ sender: Any) {
        scrollToBottom() {}
    }
    
    var sectionChatData: [[Chat]] = []
}

extension ViewController {
    func calcSectionData() {
        sectionChatData = []
        var prevTime = "25:00"

        for (index, data) in chatData.enumerated() {
            guard !sectionChatData.isEmpty else {
                sectionChatData = [[data]]
                prevTime = data.sentTime
                continue
            }
            
            if prevTime != data.sentTime {
                sectionChatData.append([data])
                prevTime = data.sentTime
            } else {
                sectionChatData[sectionChatData.count - 1].append(data)
            }
        }

//        for dt in sectionChatData {
//            print("-------------",dt.last?.sentTime,"-----------------")
//            for dt_ in dt {
//                print(dt_.chatId, dt_.sentTime)
//            }
//        }
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
        
        goBackButton.setTitle(String(DataStorage.instance.getUserList(roomId: roomId).count), for: .normal)
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
extension ViewController:  UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching{
    
    
    func scrollToBottom(completionHandler: @escaping () -> Void) {
        guard self.chatData.count > 0 else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatData.count - 1, section: 0)

            self.contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
            completionHandler()
        }
        scrollToBottomButton.isHidden = true
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        print(sectionChatData.count)
//        return sectionChatData.count
//    }
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        return sectionChatData[section].last?.sentTime
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return cellDataSource.count
//    }
    
    private func prefetchData(index: Int) {
        let data = chatData[index]
        DispatchQueue.main.async {
            if let appendedImage = UIImage(data: data.image) {
                guard ImageManager.shared.imageCache.object(forKey: NSString(string: String(data.chatId))) == nil else {
                    return
                }

                let cachedImage = ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
                
                ImageManager.shared.imageCache.setObject(cachedImage, forKey: NSString(string: String(data.chatId)))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            self.prefetchData(index: indexPath.row)
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if chatData[indexPath.row].text.isEmpty{
//            return Constants.imageSize
//        }else {
//            return
//        }
//    }

    func setCellData(_ uid: Int, _ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool) -> UITableViewCell {
        if uid != me {
            guard case let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
                return UITableViewCell()
            }
            cell.setData(data, shouldShowTimeLabel, shouldShowUserInfo)
            
            return cell
        }else{
            guard case let cell = MyChatCell.dequeueReusableCell(tableView: contentTableView) else {
                return UITableViewCell()
            }
            
            cell.setData(data, shouldShowTimeLabel, shouldShowUserInfo)
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionChatData.index
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let curData = chatData[indexPath.row]
        let uid = curData.owner.userId

        guard indexPath.row > 0,
              let prevData = chatData[indexPath.row - 1] as? Chat
        else {
            return setCellData(uid, curData, true, true)
        }
        
        let shouldShowUserInfo = uid != prevData.owner.userId
        
//        if indexPath.section + 1 >= sectionChatData.count {
//            if indexPath.row + 1 >= sectionChatData[indexPath.section].count {
//                return setCellData(uid, curData, true, shouldShowUserInfo)
//            } else {
//                nextData = sectionChatData[indexPath.section][indexPath.row + 1]
//            }
//        } else {
//            if indexPath.row + 1 >= sectionChatData[indexPath.section].count {
//                nextData = sectionChatData[indexPath.section + 1][0]
//            } else {
//                nextData = sectionChatData[indexPath.section][indexPath.row + 1]
//            }
//        }
//
//
//        if indexPath.row + 1 >= sectionChatData[indexPath.section].count {
//            if indexPath.section + 1 >= sectionChatData.count {
//                return setCellData(uid, curData, true, shouldShowUserInfo)
//            } else {
//                nextData = sectionChatData[indexPath.section + 1][0]
//            }
//        } else {
//            nextData = sectionChatData[indexPath.section][indexPath.row + 1]
//        }
        
        
        guard indexPath.row + 1 < chatData.count,
              let nextData = chatData[indexPath.row + 1] as? Chat
        else {
            return setCellData(uid, curData, true, shouldShowUserInfo)
        }
        
        let shouldShowTimeLabel = (uid != nextData.owner.userId || curData.sentTime != nextData.sentTime)
        
        return setCellData(uid, curData, shouldShowTimeLabel, shouldShowUserInfo)
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
    func onTopReached() {
        print("loading!")
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
            self.loadData()
            
            self.contentTableView.reloadData()
            
            self.isLoading = false
        }
    }
    
    
    // 스크롤 버튼 표시 관리
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        let offsetValue = scrollView.contentSize.height - (scrollView.bounds.size.height + scrollView.contentOffset.y)
        
        if scrollView.contentOffset.y < Constants.loadThreshold && !isLoading && !isEndReached {
            onTopReached()
        }
        
        ///velocity: 양수일 경우 위로 스크롤 중
        ///offsetValue: 스크롤뷰의 가장 아래서부터의 contentOffset 값
        if velocity >= 0 && offsetValue > Constants.deviceSize.height && scrollToBottomButton.isHidden {
            scrollToBottomButton.isHidden = false
        }else if velocity <= 0 && offsetValue < 10 && scrollView.isDecelerating && !scrollToBottomButton.isHidden {
            scrollToBottomButton.isHidden = true
        }
    }
}

// 갤러리 접근
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        chatData.append( DataStorage.instance.appendChatData(roomId: roomId, owner: userList[selectedUser], image: imageData))
        
        ImageManager.shared.saveImageToCache(image: UIImage(data: chatData.last!.image)!, id: chatData.last!.chatId)
        
        scrollToBottom() {
            picker.dismiss(animated: true)
        }
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func openPhotoLibrary() {
        var configuration = PHPickerConfiguration()
        
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           
           picker.dismiss(animated: true) // 1
           
           let itemProvider = results.first?.itemProvider // 2
           
           if let itemProvider = itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
               itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
                   DispatchQueue.main.async {
                       guard let image = image as? UIImage,
                             let imageData = image.pngData()
                       else {
                           return
                       }
                       
                       self.chatData.append( DataStorage.instance.appendChatData(roomId: self.roomId, owner: self.userList[self.selectedUser], image: imageData))
                       
                       self.scrollToBottom() {
                           picker.dismiss(animated: true)
                       }
                   }
               }
           } else {
               // TODO: Handle empty results or item provider not being able load UIImage
           }
       }

}
