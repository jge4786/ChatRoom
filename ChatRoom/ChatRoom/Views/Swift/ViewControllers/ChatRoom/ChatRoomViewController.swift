import UIKit
import PhotosUI
import RxSwift
import RxCocoa

class ChatRoomViewController: UIViewController {
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    
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
    
    @IBOutlet weak var selectUserButton: UIButton!
    
    
    var goBackButton_ = UIButton().then {
        $0.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        $0.setImage(UIImage(systemName: "chevron-backward"), for: .normal)
    }
    
    @objc
    func onPressGoBack() {
        
    }
    
    @IBAction func onPressGoBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPressEmojiButton(_ sender: Any) {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
//                inputTextView
            }
        }
    }
    @IBAction func onPressAddImageButton(_ sender: Any) {
        openPhotoLibrary()
    }
    

    // 전송 버튼 눌림
    @IBAction func onPressSendMessageButton(_ sender: Any) {
        DataStorage.instance.isGPTRoom(roomId: roomId)
        ? sendMessageToGPT()
        : sendMessage()
    }
    
    @IBAction func onPressScrollToBottom(_ sender: Any) {
        scrollToBottom()
    }
    
    var drawerState = false
    @IBAction func onPressMenuButton(_ sender: Any) {
        drawerShowAndHideAnimation(isShow: !drawerState)
        drawerState = !drawerState
    }
    
    let temporaryGptDataSetId = 0
    
    var drawerView = UIView().then {
        $0.backgroundColor = UIColor(cgColor: Color.DarkGray)
    }
    
    var deleteDataButton = UIButton().then {
        $0.backgroundColor = UIColor(cgColor: Color.DarkYellow)
        $0.tintColor = UIColor(cgColor: Color.Yellow)
        $0.setTitle("삭제", for: .normal)
    }
    
    
    let storage = DataStorage.instance
    
    var chatRoomInfo: (userId: Int, roomId: Int) = (userId: 5, roomId: 0)
    var me = 5
    var roomId = 0
    var selectedUser = 5
    var gptInfo: User? = nil
    
    var userData: User = User()
    var roomData: ChatRoom = ChatRoom()
    
    
    var isLoading = false
    
    var isEndReached = false
    var offset = 0
    
    var safeAreaBottomInset: CGFloat = 0.0
    
    var isInitialLoad = true
    
    // 입력창 높이
    var textViewLine = 1 {
        didSet {
            if oldValue == textViewLine {
            }else{
                guard let lineHeight = inputTextView.font?.lineHeight else { return }
                
                let direction: Double = Double(textViewLine - oldValue)
                let translationValue = lineHeight * direction
                
                contentTableView.contentOffset.y = contentTableView.contentOffset.y + translationValue
            }
        }
    }
    

    var chatData: [Chat] = [] {
        willSet {
            if chatData.count <= newValue.count {
                guard newValue.last != nil else { return }
            }
        }
        didSet {
            print("몇번?", isInitialLoad)
            
            guard !isInitialLoad else { isInitialLoad = false; return; }
            contentTableView.reloadData()
        }
    }
    
    var gptMessageData: [Message] = []

    
    // **************** 테스트용 ***************
    
    
    var userList: [User] = []
    
    func selectUser(selected: Int) {
        selectedUser = selected
        selectUserButton.setTitle(userList[selected].name, for: .normal)
    }
    // ***************************************
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSettings()
        
        view.addSubview(drawerView)
        drawerView.addSubview(deleteDataButton)
        
        drawerView.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(inputTextViewWrapper.snp.top)
            make.width.equalTo(0.0)
        }
        
        deleteDataButton.snp.makeConstraints {
            $0.trailing.leading.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        deleteDataButton.addTarget(self, action: #selector(onPressDeleteDataButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hidingBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func drawerShowAndHideAnimation(isShow: Bool) {
        let deviceSize = UIScreen.main.bounds.size
        switch isShow {
        case true:
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) {
                self.drawerView.snp.updateConstraints { make in
                    make.width.equalTo(deviceSize.width * 0.4)
                }
                self.view.layoutIfNeeded()
            }
        case false:
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) {
                self.drawerView.snp.updateConstraints { make in
                    make.width.equalTo(0)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
        
    @objc
    func onPressDeleteDataButton() {
        DataStorage.instance.deleteChatData(roomId: roomId)
        if gptInfo != nil {
            print("지피티 초기화")
            DataStorage.instance.deleteGptChatData(dataSetId: 0)
        }
        chatData = []
        contentTableView.reloadData()
    }
    
    deinit{
        DataStorage.instance.saveData()
        print("ChatRoomViewController deinit")
    }
}



extension ChatRoomViewController: ChangeSceneDelegate {
    func goToChatDetailScene(chatId: Int) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatDetail") as? ChatDetailViewController else {
            return
        }
        
        nextVC.chatId = chatId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}