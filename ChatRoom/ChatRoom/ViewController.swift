//
//  ViewController.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var contentTableView: UITableView!
    
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        addImageButton.setTitle("", for: .normal)
        sendMessageButton.setTitle("", for: .normal)
    }
}


// 키보드
extension ViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardWillShowAndHide),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardWillShowAndHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    @objc func keyBoardWillShowAndHide(notification: NSNotification) {
        let userInfo = notification.userInfo
        guard let endValue = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
        guard let durationValue = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] else { return }
        
        guard let keyboardHeight = (endValue as? CGRect)?.size.height else { return }
        
        let duration = (durationValue as AnyObject).doubleValue
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            contentWrapperView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            contentTableView.contentInset.top = keyboardHeight
            contentTableView.contentInset.bottom = inputTextView.frame.height
        case UIResponder.keyboardWillHideNotification:
            contentTableView.transform = .identity
            contentTableView.contentInset.top = 0
            contentTableView.contentInset.bottom = 0
        default:
            break
        }
    }
    
}



extension ViewController:  UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bubble", for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        
        cell.titleLabel.text = Constants.users[indexPath.row].name
        cell.contentLabel.text = Constants.users[indexPath.row].name+"asdf"
        
        return cell
    }
}

extension UIViewController {
        
    func recognizeHidingKeyboardGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer (
            target: self, action: #selector(UIViewController.dissmissKeyboard)
            )
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
    }
}
