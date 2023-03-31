import UIKit

class ChatRoomListController: UIViewController {
    @IBOutlet weak var secondRoomButton: UIButton!
    @IBOutlet weak var firstRoomButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstRoomButton.setTitle(DataStorage.instance.getChatRoom(roomId: 0)?.roomName, for: .normal)
        secondRoomButton.setTitle(DataStorage.instance.getChatRoom(roomId: 1)?.roomName, for: .normal)
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
            DataStorage.instance.makeChatRoom(roomId: 1, userId: 2)
        }
        
        nextVC.chatRoomInfo = (userId: 2, roomId: 1)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("나타난다")
    }
}
