import UIKit

class ChatDetailViewController: UIViewController {
    var chatId: Int = 0
    
    @IBAction func onPressGoBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var imageDetailView: UIImageView!
    @IBOutlet weak var textDetailView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchView = UISearchBar().then {
            $0.isHidden = true
        }
        
        self.navigationItem.titleView = searchView

        guard let data = DataStorage.instance.getChat(chatId: chatId) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if let navigationController = self.navigationController {
            navigationController.isNavigationBarHidden = false
        }
        
        goBackButton.title = ""
        self.navigationItem.title = ""
       if data.text.isEmpty {
           textDetailView.isHidden = true
           let image = UIImage(data: data.image)
           
           imageDetailView.image = image
       } else {
           imageDetailView.isHidden = true
           textDetailView.text = data.text
       }
    }
}
