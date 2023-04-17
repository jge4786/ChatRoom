import UIKit
import PhotosUI
import RxSwift
import RxCocoa

class ChatRoomViewController: UIViewController {
    
    
    let chatViewModel = ChatViewModel()
    
    func setBind() {
        
        bindImagePicker()
        bindSearch()
        bindScroll()
        bindTableView()
        bindInput()
    }
    
    func bindInput() {
        chatViewModel.inputButtonHiddenState.bind { [weak self] in
            guard let self = self else { return }
            
            self.emojiButton.isHidden = $0.emoji
            self.sendMessageButton.isHidden = $0.message
            
        }
    }
    
    func bindScroll() {
        
    }
    
    func bindImagePicker() {
        //이미지피커 열기
        chatViewModel.configuration.bind { [weak self] in
            guard let configuration = $0 else  { return }
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            self?.present(picker, animated: true)
        }
        
        chatViewModel.image.bind { [weak self] in
            guard let _ = $0 else { return }
            self?.scrollToBottom()
        }
    }
    
    
    func bindSearch() {
        // 검색된 결과로 이동
        chatViewModel.targetIndex.bind { [weak self] in
            guard let self = self,
                  let index = $0
            else { return }
            
            self.contentTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .bottom, animated: false)
            
            self.playSearchAnimaionOnCell(index: index)
        }
        
        // 이전 / 다음 검색 버튼 활성화 관리
        chatViewModel.searchButtonState.bind { [weak self] in
            guard let self = self else { return }
            
            self.emojiButton.isEnabled = $0.next
            self.sendMessageButton.isEnabled = $0.prev
        }
    }
    
    func bindTableView() {
        chatViewModel.chatData.bind { [weak self] in
            guard let self = self
            else { return }
            
            if $0.first?.owner.userId == 0,
               $0.first?.text == "..." {
                self.messageLoadingIndicator.startAnimating()
            } else {
                self.messageLoadingIndicator.stopAnimating()
            }
            
            self.contentTableView.reloadData()
        }
    }
    
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
    
    @IBOutlet weak var footerButtonStackView: UIStackView!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var letterCountWrapperView: UIView!
    @IBOutlet weak var letterCountLabel: UILabel!
    @IBOutlet weak var scrollToBottomButton: UIButton!  // 가장 밑으로 스크롤
    
    @IBAction func onPressGoBackButton(_ sender: Any) {
        if searchBar.isHidden {
            self.navigationController?.popViewController(animated: true)
        } else {
            onPressSearchButton()
        }
    }
    
    @IBAction func onPressSearchButton(_ sender: Any) {
        handleSearchBar()
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
    @objc
    @IBAction func onPressSendMessageButton(_ sender: Any) {
        
        guard searchBar.isHidden else { return }
        
        sendMessage(owner: userData,
                    text: inputTextView.text,
                    isUser: DataStorage.instance.isGPTRoom(roomId: roomId))
        
//        DataStorage.instance.isGPTRoom(roomId: roomId)
//        ? sendMessageToGPT()
//        : sendMessage(owner: userData, text: inputTextView.text)
    }
    
    // 하단 스크롤 버튼 눌림
    @IBAction func onPressScrollToBottom(_ sender: Any) {
        scrollToBottom()
    }
    
    @objc
    func onPressMenuButton(_ sender: Any) {
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
    
    var searchBarWrapperView = UIView()
    var searchBar = UISearchBar().then {
        $0.backgroundColor = Color.Black
        $0.isHidden = true
        $0.showsCancelButton = false
    }
    
    var searchButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "magnifyingglass")
    }
    
    var menuButton = UIBarButtonItem().then {
        $0.image = UIImage(systemName: "ellipsis")
    }
    
    var searchNextButton = UIButton().then {
        $0.tintColor = .black
        $0.setTitle("", for: .normal)
        $0.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
    }
    
    var searchPrevButton = UIButton().then {
        $0.tintColor = .black
        $0.setTitle("", for: .normal)
        $0.setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .normal)
    }
        
    //채팅방 기본 정보
    var chatRoomInfo: (userId: Int, roomId: Int) = (userId: 5, roomId: 0)   // ChatRoomListController 에서 넘기는 값을 저장
    var roomId = 0          // 현재 방의 userId
    var gptInfo: User? = nil
    
    var userData: User = User()
    var roomData: ChatRoom = ChatRoom()
    
    var searchIndex = 0
    var searchKeyword: String = ""
    var searchResult: [Chat] = []
    
    func addSearchBar() {
        navBar.rightBarButtonItems = [menuButton, searchButton]
        searchButton.action = #selector(handleSearchBar)
        searchButton.target = self
        menuButton.action = #selector(onPressMenuButton)
        menuButton.target = self
        self.extendedLayoutIncludesOpaqueBars = true
        searchBar.searchTextField.leftView = nil
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    //채팅 데이터 관리
    
    var isLoading = false       //짧은 시간에 여러번 로딩되는 것 방지
    var isEndReached = false    //모든 데이터 로딩 완료됐는지
    var offset = 0
    var isInitialLoad = true    //이 채팅방에서의 첫 로딩인지
    
//    var chatData: [Chat] = [] {
//        willSet {
//            if chatData.count <= newValue.count {
//                guard newValue.last != nil else { return }
//            }
//        }
//        didSet {
//            guard !isInitialLoad else { isInitialLoad = false; return; }
//            contentTableView.reloadData()
//        }
//    }
    
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
        
        setBind()
        
        
        
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
        
        chatViewModel.handleDeinitProcess()
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
