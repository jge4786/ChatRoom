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
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var inputTextViewWrapper: UIView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    
    var textInputReturnCount = 0
    
    let textInputDefaultInset = 6.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.deviceSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        self.inputTextView.delegate = self
        
        addImageButton.setTitle("", for: .normal)
        sendMessageButton.setTitle("", for: .normal)
        
        inputTextViewHeight.constant = getTextViewHeight()
        
        initHeaderButtonsSetting()
        initTextView()
        
        ChatTableViewCell.register(tableView: contentTableView)
    }
}

// 입력창
extension ViewController {
    func initTextView() {
        inputTextViewWrapper.layer.cornerRadius = 15
        inputTextViewWrapper.layer.borderWidth = 1
        inputTextViewWrapper.layer.borderColor = Color.DarkerGray
    }
}

// 헤더
extension ViewController {
    func initHeaderButtonsSetting() {
        searchButton.setTitle("", for: .normal)
        searchButton.tintColor = UIColor(cgColor: Color.White)
        
        menuButton.setTitle("", for: .normal)
        menuButton.tintColor = UIColor(cgColor: Color.White)
        
        goBackButton.setTitle(String(Constants.users.count), for: .normal)
        goBackButton.tintColor = UIColor(cgColor: Color.White)
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
        case UIResponder.keyboardWillHideNotification:
            contentWrapperView.transform = .identity
            contentTableView.contentInset.top = 0
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
        guard case let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
            return UITableViewCell()
        }

        cell.setData(Constants.chatData[indexPath.row])
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
        return inputTextView.getTextViewSize().height
    }

    public func setTextViewHeight() {
        guard inputTextView.numberOfLines() <= 5 else { return }
        
        inputTextViewHeight.constant = getTextViewHeight()
    }
    
    func setSendMessageButtonImage(isEmpty: Bool) {
        sendMessageButton.setImage(UIImage(systemName: isEmpty ? "moon" : "paperplane"), for: .normal)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        setTextViewHeight()
        setSendMessageButtonImage(isEmpty: textView.text.isEmpty)
    }
}

extension UITextView {
    func getTextViewSize() -> CGSize {
        let size = CGSize(width: self.frame.width, height: .infinity)
        
        let estimatedSize = self.sizeThatFits(size)
        
        return estimatedSize
    }
    
    func getTextViewHeight(limit: Int = 0) -> (Double, Bool) {
        guard self.numberOfLines() > 0 && self.numberOfLines() <= limit else {
            return (Double(self.font!.lineHeight) * Double(limit), false)
        }
        
        return (self.getTextViewSize().height, true)
    }
        
    func numberOfLines() -> Int {
        let size = getTextViewSize()
        
        return Int(size.height / self.font!.lineHeight)
    }
}
