import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

//TODO: 다른 구조(채팅방 이외)의 화면이 추가되었을 때도 대응되도록 변경

class ChatRoomListController: UIViewController {    
    var roomListScrollView = UIScrollView()
    
    var roomStackView = UIStackView().then {
        $0.backgroundColor = .black
    }
    
    var roomButton = UIButton().then {
        $0.backgroundColor = Color.LightBlack
    }

    var addNewRoomButton = UIButton().then {
        $0.backgroundColor = .black
        $0.alpha = 0.6
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = Color.White
    }
    
    var tabId: TabBarIdentifier = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.DarkGray
    }
    
    func initialize() {
        setSubViews()
        setConstraints()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hidingBar()
        
        roomStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        roomStackView.removeFromSuperview()
        initialize()
    }
    func hidingBar() {
        guard let tabBarController = self.tabBarController
        else {
            return
        }
        
        tabBarController.tabBar.isHidden = false
    }
    
    func addRoomButton(key: Int) {
        let button = UIButton().then {
            $0.backgroundColor = Color.Black
            $0.tag = key
        }
        
        roomStackView.addArrangedSubview(button)
    }
    
    func setSubViews() {
        view.addSubview(roomListScrollView)
        view.addSubview(addNewRoomButton)
        
        roomListScrollView.addSubview(roomStackView)
        
        switch tabId {
        case .normal:
            for data in DataStorage.instance.getChatRoomList() {
                guard !DataStorage.instance.isGPTRoom(roomId: data.roomId) else { continue }
                
                addRoomButton(key: data.roomId)
            }
        case .gpt:
            for data in DataStorage.instance.getGptDataSetList() {
                addRoomButton(key: data.key)
            }
        case _:
            print("탭바 에러")
        }
    }
    
    func setConstraints() {
        roomListScrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        
        roomStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        for button in roomStackView.subviews {
            button.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()

                $0.height.equalTo(50)
            }
        }
        
        addNewRoomButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(roomListScrollView).inset(10)
        }
    }
    
    
    func setData() {
        roomStackView.axis = .vertical
        roomStackView.spacing = 3
        roomStackView.distribution = .equalSpacing
        
        
        switch tabId {
        case .gpt:
            for button in roomStackView.subviews {
                guard let button = button as? UIButton else { return }
                button.setTitle("GPT \(button.tag)", for: .normal)
                button.addTarget(self, action: #selector(onPressGPTButton), for: .touchUpInside)
            }
        case .normal, _:
            for button in roomStackView.subviews{
                guard let button = button as? UIButton else { return }
                button.setTitle(DataStorage.instance.getChatRoom(roomId: button.tag)?.roomName, for: .normal)
                
                button.addTarget(self, action: #selector(onPressRoomEnteranceButton), for: .touchUpInside)
            }
        }
        
        addNewRoomButton.addTarget(self, action: #selector(onPressAddNewRoomButton), for: .touchUpInside)

    }
    
    func setBiding() {
        
    }
    
    @objc
    func onPressAddNewRoomButton() {
        switch tabId {
        case .gpt:
            DataStorage.instance.makeChatGPTRoom()
        //case .normal: fallthrough
        //case _:
        case .normal, _:
            DataStorage.instance.makeChatRoom(name: "newRoom \(DataStorage.instance.getChatRoomList().count)")
        }
        DataStorage.instance.saveData()
        roomStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        roomStackView.removeFromSuperview()
        initialize()
    }
    
    @objc
    func onPressGPTButton(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ChatRoomViewController else { return }
        guard let btn = sender as? UIButton else { return }
        
        nextVC.chatRoomInfo = (userId: 1, roomId: btn.tag)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc
    func onPressRoomEnteranceButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ChatRoomViewController else {
            return
        }

        nextVC.chatRoomInfo = (userId: 2, roomId: button.tag)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    deinit {
        DataStorage.instance.saveData()
    }
}
