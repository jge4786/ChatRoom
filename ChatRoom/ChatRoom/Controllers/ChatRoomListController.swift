import UIKit

class ChatRoomListController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ㅇㅇㅇ")
    }
    @IBAction func onPressEnterChatRoomButton(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoom") as? ViewController else {
            return
        }
        
        nextVC.chatRoomInfo = (userId: 5, roomId: 0)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("나타난다")
    }
}
