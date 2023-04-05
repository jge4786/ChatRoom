import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class ChatRoomListController: UIViewController {
    @IBOutlet weak var secondRoomButton: UIButton!
    @IBOutlet weak var firstRoomButton: UIButton!
    @IBOutlet weak var gptButton: UIBarButtonItem!
    
    var tabBar = UITabBarController()
    
    let modelView = ChatRoomListModelView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstRoomButton.setTitle(DataStorage.instance.getChatRoom(roomId: 0)?.roomName, for: .normal)
        secondRoomButton.setTitle(DataStorage.instance.getChatRoom(roomId: 1)?.roomName, for: .normal)
        
        setSubViews()
        setConstraints()
        setData()
        
    }
    
    func setSubViews() {
        
    }
    
    func setConstraints() {
        
    }
    
    
    func setData() {
    }
    
    func setBiding() {
        
    }
    @IBAction func onPressGPTButton(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ViewController else { return }

        print("wow \(DataStorage.instance.getGPTRoom())")

        nextVC.chatRoomInfo = (userId: 1, roomId: DataStorage.instance.getGPTRoom())
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onPressEnterFirstChatRoomButton(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ViewController else {
            return
        }
        
        nextVC.chatRoomInfo = (userId: 5, roomId: 0)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func onPressEnterSecondChatRoomButton(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ViewController else {
            return
        }
        
        if DataStorage.instance.getChatRoom(roomId: 1) == nil {
            DataStorage.instance.makeChatRoom(name: "새로운 채팅방")
        }
        
        nextVC.chatRoomInfo = (userId: 2, roomId: 1)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
