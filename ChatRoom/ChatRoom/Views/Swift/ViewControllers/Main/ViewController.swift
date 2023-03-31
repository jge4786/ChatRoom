import UIKit
import PhotosUI

class ViewController: UIViewController {
    let storage = DataStorage.instance
    
    var chatRoomInfo: (userId: Int, roomId: Int) = (userId: 5, roomId: 0)
    var me = 5
    var roomId = 0
    var selectedUser = 5
    
    var userData: User = User()
    var roomData: ChatRoom = ChatRoom()
    
    
    var isLoading = false
    
    var isEndReached = false
    var offset = 0
    
    var safeAreaBottomInset: CGFloat = 0.0
    
    var isInitialLoad = true
    
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
    
    // **************** 테스트용 ***************
    
    
    var userList: [User] = []
    
    @IBOutlet weak var selectUserButton: UIButton!
    
    func selectUser(selected: Int) {
        selectedUser = selected
        selectUserButton.setTitle(userList[selected].name, for: .normal)
    }
    // ***************************************
    
    
    
    
    
    
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
        sendMessage()
    }
    
    @IBAction func onPressScrollToBottom(_ sender: Any) {
        scrollToBottom() { [weak self] in }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSettings()
    }
    
    deinit{
        DataStorage.instance.saveData()
        print("ViewController deinit")
    }
}



extension ViewController: ChangeSceneDelegate {
    func goToChatDetailScene(chatId: Int) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatDetail") as? ChatDetailViewController else {
            return
        }
        
        nextVC.chatId = chatId
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
