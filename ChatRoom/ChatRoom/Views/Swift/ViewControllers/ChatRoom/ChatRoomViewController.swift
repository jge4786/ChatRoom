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
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!        // 이미지 첨부 버튼
    
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var letterCountWrapperView: UIView!
    @IBOutlet weak var letterCountLabel: UILabel!
    @IBOutlet weak var scrollToBottomButton: UIButton!  // 가장 밑으로 스크롤
    
    @IBOutlet weak var dataLoadingScreen: UIView!
    
    @IBAction func onPressGoBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPressEmojiButton(_ sender: Any) {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
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
    
    // 하단 스크롤 버튼 눌림
    @IBAction func onPressScrollToBottom(_ sender: Any) {
        scrollToBottom()
    }
    
    @IBAction func onPressMenuButton(_ sender: Any) {
        drawerShowAndHideAnimation(isShow: !drawerState)
        drawerState = !drawerState
    }
    
    //채팅방 삭제
    @objc
    func onPressDeleteDataButton() {
        DataStorage.instance.deleteChatData(roomId: roomId)
        if gptInfo != nil {
            DataStorage.instance.deleteGptChatData(dataSetId: roomId)
        }
        
        DataStorage.instance.deleteChatRoom(roomId: roomId)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    var drawerView = UIView().then {
        $0.backgroundColor = Color.DarkGray
    }
    
    var deleteDataButton = UIButton().then {
        $0.backgroundColor = Color.DarkYellow
        $0.tintColor = Color.Yellow
        $0.setTitle("삭제", for: .normal)
    }
    
    var goBackButton_ = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "chevron-backward"), for: .normal)
    }
    
    //채팅방 기본 정보
    var chatRoomInfo: (userId: Int, roomId: Int) = (userId: 5, roomId: 0)   // ChatRoomListController 에서 넘기는 값을 저장
    var roomId = 0          // 현재 방의 userId
    var gptInfo: User? = nil
    
    var userData: User = User()
    var roomData: ChatRoom = ChatRoom()
    
    
    
    
    //채팅 데이터 관리
    
    var isLoading = false       //짧은 시간에 여러번 로딩되는 것 방지
    var isEndReached = false    //모든 데이터 로딩 완료됐는지
    var offset = 0
    var isInitialLoad = true    //이 채팅방에서의 첫 로딩인지
    
    var chatData: [Chat] = [] {
        willSet {
            if chatData.count <= newValue.count {
                guard newValue.last != nil else { return }
            }
        }
        didSet {
            guard !isInitialLoad else { isInitialLoad = false; return; }
            contentTableView.reloadData()
        }
    }
    
    //UI 관련
    var drawerState = false
    var safeAreaBottomInset: CGFloat = 0.0
    
    
    // 입력창 높이
    var textViewLine = 1 {
        didSet {
            if oldValue == textViewLine {
            } else {
                guard let lineHeight = inputTextView.font?.lineHeight else { return }
                
                let direction: Double = Double(textViewLine - oldValue)
                let translationValue = lineHeight * direction
                
                contentTableView.contentOffset.y = contentTableView.contentOffset.y + translationValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //탭바 숨김
        hidingBar()
    }
    
    //TODO: 서랍이 들어가 있을 때는 hidden으로 설정하기
    func drawerShowAndHideAnimation(isShow: Bool) {
        let deviceSize = UIScreen.main.bounds.size
        switch isShow {
        case true:
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) {
                self.drawerView.transform = CGAffineTransform(translationX: -deviceSize.width * 0.4, y: 0)
                self.view.layoutIfNeeded()
            }
        case false:
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) {
                self.drawerView.transform = .identity
                self.view.layoutIfNeeded()
            }
        }
    }
       
    deinit{
        DataStorage.instance.saveData()
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
