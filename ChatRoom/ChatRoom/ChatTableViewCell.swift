//
//  ChatTableViewCell.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell, TableViewCellBase {
    var data: Chat = Chat() {
        didSet {
            nameLabel.text = data.owner.name
            unreadCountLabel.text = getUnreadCountText(cnt: data.unreadCount)
            sentTimeLabel.text = data.sentTime
            chatBubbleTextView.text = data.text
            
            chatBubbleHeight.constant = chatBubbleTextView.getTextViewHeight(limit: Constants.chatHeightLimit, gap: profileButtonWidth.constant + infoView.frame.width).0
            
            // 이미지 나오지 않는 문제 관련 링크
            ///https://www.dev2qa.com/how-to-fix-image-not-showing-error-for-swift-button
            profileButton.setImage(UIImage(named: Constants.defaultImages[data.owner.uid])?.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
    }
    
    @IBOutlet weak var profileButtonWrapperView: UIView!
    @IBOutlet weak var opacityFilterView: UIView!
    @IBOutlet weak var chatBubbleHeight: NSLayoutConstraint!
    @IBOutlet weak var chatBubbleView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var chatBubbleButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var sentTimeLabel: UILabel!
    
    @IBOutlet weak var chatBubbleTextView: UITextView!
    
    @IBOutlet weak var profileButtonWidth: NSLayoutConstraint!
    @IBAction func onTouchInChatBubble(_ sender: Any) {
        print("touchIn")
        manageButtonHighlightAnim(isShow: true)
    }
    
    //버튼 터치 시 실행할 함수 정의
    @IBAction func onTouchOutChatBubble(_ sender: Any) {
        print("touchOut", chatBubbleTextView.text ?? "")
        manageButtonHighlightAnim(isShow: false)
    }
    
    @IBAction func onTouchCanceled(_ sender: Any) {
        print("canceled")
        manageButtonHighlightAnim(isShow: false)
    }
    
    func manageButtonHighlightAnim(isShow: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
            self.opacityFilterView.layer.opacity = isShow ? 0.3 : 0.0
        }
    }
        
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var chatBubbleMaxWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chatBubbleButton.setTitle("", for: .normal)
        chatBubbleView.layer.cornerRadius = 10
        chatBubbleView.backgroundColor = UIColor(cgColor: Color.White)
//        chatBubbleButton.tintColor = UIColor(cgColor: Color.Black)
        
        profileButton.setTitle("", for: .normal)
        
        nameLabel.text = data.owner.name
        unreadCountLabel.text = getUnreadCountText(cnt: 0)
        sentTimeLabel.text = "00:00"
        
//        print(infoView.frame.width)
        
        chatBubbleMaxWidth.constant = (Constants.deviceSize.width) * Constants.chatMaxWidthMultiplier
        
        
        profileButton.layoutIfNeeded()
        profileButton.layer.cornerRadius = profileButton.frame.height / 2.65
        profileButton.layoutIfNeeded()
    }
    
    private func getUnreadCountText(cnt: Int) -> String {
        guard cnt > 0 else { return "" }
        
        return String(cnt)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ chat: Chat) {
        self.data = chat
    }
}
