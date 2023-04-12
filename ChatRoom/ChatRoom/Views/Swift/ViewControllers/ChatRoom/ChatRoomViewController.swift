import UIKit
import PhotosUI
import RxSwift
import RxCocoa

class ChatRoomViewController: UIViewController {
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var contentTableView: UITableView!
    
//    @IBOutlet weak var menuButton: UIBarButtonItem!
//    @IBOutlet weak var searchButton: UIBarButtonItem!
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
    
    @IBAction func onPressGoBackButton(_ sender: Any) {
        if isSearching {
            isSearching = false
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onPressSearchButton(_ sender: Any) {
        isSearching = !isSearching
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
        guard !isDrawerAnimIsPlaying else { return }
        
        view.endEditing(true)
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
    
    //서랍이 나왔을 때, 배경을 블러처리하는 뷰
    var contentBlurView = UIView().then {
        $0.backgroundColor = .black
        $0.alpha = 0.0
    }
    
    var drawerView = UIView().then {
        $0.backgroundColor = Color.DarkGray
    }
    
    
    var drawerRoomScrollView = UIScrollView()
    var drawerRoomStackView = UIStackView().then {
        $0.backgroundColor = .black
        $0.axis = .vertical
        $0.spacing = 1
    }
    
    var deleteDataButton = UIButton().then {
        $0.backgroundColor = .black
        $0.setTitle("채팅방 삭제", for: .normal)
    }
    
    var goBackButton_ = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "chevron-backward"), for: .normal)
    }
    
    var messageLoadingIndicator = UIActivityIndicatorView().then {
        $0.color = .white
        $0.isHidden = true
    }
    
    var searchButton = UIButton().then {
        $0.tintColor = Color.White
        $0.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    }
    var menuButton = UIButton().then {
        $0.tintColor = Color.White
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
    }
    
    var searchBar = UISearchBar().then {
        $0.backgroundColor = Color.LightBlue
        $0.isHidden = true
    }
    
    //채팅방 기본 정보
    var chatRoomInfo: (userId: Int, roomId: Int) = (userId: 5, roomId: 0)   // ChatRoomListController 에서 넘기는 값을 저장
    var roomId = 0          // 현재 방의 userId
    var gptInfo: User? = nil
    
    var userData: User = User()
    var roomData: ChatRoom = ChatRoom()
    
    
    func handleSearchBar(isShow: Bool) {
        if isShow {
            searchBar.isHidden =  true
        }
    }
    
    func addSearchBar() {
        let searchBtn       = UIBarButtonItem(customView: searchButton),
            menuBtn         = UIBarButtonItem(customView: menuButton),
            searchBarItem   = UIBarButtonItem(customView: searchBar)
        
        
        self.navigationItem.titleView = searchBar
//        searchTextField.snp.makeConstraints {
//            $0.top.leading.bottom.trailing.equalToSuperview()
//        }
    }
    
    var isSearching = false {
        didSet {
            handleSearchBar(isShow: isSearching)
        }
    }
    
    //채팅 데이터 관리
    
    var isLoading = false       //짧은 시간에 여러번 로딩되는 것 방지
    var isEndReached = false    //모든 데이터 로딩 완료됐는지
    var offset = 0
    var isInitialLoad = true    //이 채팅방에서의 첫 로딩인지
    
    var dataTask: URLSessionDataTask? = nil
    
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
    var isDrawerAnimIsPlaying = false
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
        
        addSearchBar()
        
        initializeSettings()
        
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //탭바 숨김
        hidingBar()
    }
    
    
    //TODO: 서랍이 들어가 있을 때는 hidden으로 설정하기
    func drawerShowAndHideAnimation(isShow: Bool) {
        let deviceSize = UIScreen.main.bounds.size
        
        isDrawerAnimIsPlaying = true
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) {
            if isShow {
                self.drawerView.transform = CGAffineTransform(translationX: -deviceSize.width * 0.7, y: 0)
                self.contentBlurView.alpha = 0.4
            } else {
                self.drawerView.transform = .identity
                self.contentBlurView.alpha = 0.0
            }
            
            self.view.layoutIfNeeded()
        } completion: { finished in
            self.isDrawerAnimIsPlaying = false
        }
    }
       
    deinit{
        print("deinit")
        
        if let dataTask = dataTask,
           chatData.first?.text == "..."
        {
            let canceledMessage = "취소된 요청입니다."
            
            if let firstIndex = chatData.first?.chatId {
                _ = DataStorage.instance.appendGptChatData(dataSetId: self.roomId, message: Message(role: "error", content: canceledMessage))
                _ = DataStorage.instance.updateChatData(roomId: roomId, chatId: firstIndex, text: canceledMessage)
            }
            
            dataTask.cancel()
        }
        
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
