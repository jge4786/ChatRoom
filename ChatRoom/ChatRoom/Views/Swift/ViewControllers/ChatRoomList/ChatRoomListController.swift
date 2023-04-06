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
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    lazy var roomButton = UIButton().then {
        $0.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    }

    var isGPT = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        setSubViews()
        setConstraints()
        setData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hidingBar()
    }
    func hidingBar() {
        guard let tabBarController = self.tabBarController,
              let navigationController = self.navigationController
        else {
            return
        }
        
        tabBarController.tabBar.isHidden = false
//        navigationController.isNavigationBarHidden = true
    }
    
    func setSubViews() {
        
        
        view.addSubview(roomListScrollView)
        
        roomListScrollView.addSubview(roomStackView)
        
        switch isGPT {
        case true:
            print("GPT!")
            roomStackView.addArrangedSubview(roomButton)
        case false:
            print("Chat!")
            for index in 0..<DataStorage.instance.getChatRoomList().count {
                guard index != DataStorage.instance.getGPTRoom() else { continue }
                
                let button = UIButton()
                
                roomStackView.addArrangedSubview(button)
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
    }
    
    
    func setData() {
        roomStackView.axis = .vertical
        roomStackView.spacing = 3
        roomStackView.distribution = .equalSpacing
        
        
        switch isGPT {
        case true:
            print("GPT!")
            roomButton.setTitle("GPT", for: .normal)
            roomButton.addTarget(self, action: #selector(onPressGPTButton), for: .touchUpInside)
        case false:
            for (index, button) in roomStackView.subviews.enumerated() {
                guard let button = button as? UIButton else { return }
                button.setTitle(DataStorage.instance.getChatRoom(roomId: index)?.roomName, for: .normal)
                button.tag = index
                button.addTarget(self, action: #selector(onPressRoomEnteranceButton), for: .touchUpInside)
            }
        }
        
        

    }
    
    func setBiding() {
        
    }
    
    @objc
    func onPressGPTButton(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ChatRoomViewController else { return }

        print("wow \(DataStorage.instance.getGPTRoom())")

        nextVC.chatRoomInfo = (userId: 1, roomId: DataStorage.instance.getGPTRoom())
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
}
