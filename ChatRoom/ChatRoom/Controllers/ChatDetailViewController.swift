//
//  ChatDetailViewController.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/31.
//

import UIKit

class ChatDetailViewController: UIViewController {
    
    var chatId: Int = 0
    
    @IBOutlet weak var imageDetailView: UIImageView!
    @IBOutlet weak var textDetailView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let data = DataStorage.instance.getChat(chatId: chatId) else {
            print("데이터 로딩 실패")
            self.navigationController?.popViewController(animated: true)
            return
        }
       if data.text.isEmpty {
           let image = UIImage(data: data.image)
           
           imageDetailView.image = image
       } else {
           textDetailView.text = data.text
       }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
