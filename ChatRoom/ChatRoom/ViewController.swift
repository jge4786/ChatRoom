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
    
    @IBOutlet weak var searchButton: EmptyTextButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    @IBOutlet weak var inputTextViewWrapper: UIView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    var textInputReturnCount = 0
    
    let textInputDefaultInset = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        self.inputTextView.delegate = self
        
        addImageButton.setTitle("", for: .normal)
        sendMessageButton.setTitle("", for: .normal)
        
        inputTextViewHeight.constant = getTextViewHeight()
        
        initHeaderButtonsText()
        initTextView()
    }
}

// 입력창
extension ViewController {
    func initTextView() {
        inputTextViewWrapper.layer.cornerRadius = inputTextViewWrapper.frame.height / 5
        
    }
}

// 헤더
extension ViewController {
    func initHeaderButtonsText() {
        searchButton.setTitle("", for: .normal)
        menuButton.setTitle("", for: .normal)
        goBackButton.setTitle(String(Constants.users.count), for: .normal)
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
//            contentTableView.contentInset.bottom = inputTextView.frame.height
        case UIResponder.keyboardWillHideNotification:
            contentWrapperView.transform = .identity
            contentTableView.contentInset.top = 0
//            contentTableView.contentInset.bottom = 0
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

extension ViewController: UITextViewDelegate {
    func getTextViewHeight() -> Double {
        return inputTextView.getTextViewSize().height + textInputDefaultInset
    }

    public func setTextViewHeight() {
        guard inputTextView.numberOfLines() < 5 else { return }
        
        inputTextViewHeight.constant = getTextViewHeight()
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        setTextViewHeight()
    }
}

extension UITextView {
    func getTextViewSize() -> CGSize {
        let size = CGSize(width: self.frame.width, height: .infinity)
        
        let estimatedSize = self.sizeThatFits(size)
        
        return estimatedSize
    }
        
    func numberOfLines() -> Int {
        let size = getTextViewSize()
        
        return Int(size.height / self.font!.lineHeight)
    }
}
