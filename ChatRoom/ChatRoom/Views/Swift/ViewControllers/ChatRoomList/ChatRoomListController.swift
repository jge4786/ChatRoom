import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class ChatRoomListController: UIViewController {
    @IBOutlet weak var gptButton: UIBarButtonItem!
    
    let modelView = ChatRoomListModelView()
    
    var roomListScrollView = UIScrollView()
    
    var roomStackView = UIStackView().then {
        $0.backgroundColor = .black
    }
    
    lazy var roomButton = UIButton().then {
        $0.backgroundColor = Color.LightBlack
    }

    var addNewRoomButton = UIButton().then {
        $0.backgroundColor = .black
        $0.layer.opacity = 0.6
        $0.layer.cornerRadius = 25
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = Color.White
    }
    
    var isGPT = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.DarkGray
        
//        initialize()
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
        
        switch isGPT {
        case true:
            print("GPT!")
//            roomStackView.addArrangedSubview(roomButton)
            
            for data in DataStorage.instance.getGptDataSetList() {
                print(data.key)
                addRoomButton(key: data.key)
            }
            
        case false:
            print("Chat!")
            for data in DataStorage.instance.getChatRoomList() {
                guard !DataStorage.instance.isGPTRoom(roomId: data.roomId) else { continue }
                print("ddd: \(data.roomId)")
                
                addRoomButton(key: data.roomId)
            }
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
        
        
        switch isGPT {
        case true:
            print("GPT!")
            for (index, button) in roomStackView.subviews.enumerated() {
                guard let button = button as? UIButton else { return }
                button.setTitle("GPT \(index)", for: .normal)
                button.addTarget(self, action: #selector(onPressGPTButton), for: .touchUpInside)
            }
        case false:
            for (index, button) in roomStackView.subviews.enumerated() {
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
        switch isGPT {
        case true:
            print("가짜")
            DataStorage.instance.makeChatGPTRoom()
        case false:
            print("진짜?")
            let newRoom = DataStorage.instance.makeChatRoom(name: "newRoom \(DataStorage.instance.getChatRoomList().count)")
            
            dump(newRoom)
            
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
