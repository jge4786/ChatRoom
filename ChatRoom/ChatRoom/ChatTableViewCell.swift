import UIKit

class ChatTableViewCell: UITableViewCell, TableViewCellBase {
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
        
        initialize()
    }
    
    
    func initialize() {
        chatBubbleButton.setTitle("", for: .normal)
        chatBubbleView.layer.cornerRadius = 10
        chatBubbleView.backgroundColor = UIColor(cgColor: Color.White)
        
        profileButton.setTitle("", for: .normal)
        
        nameLabel.text = ""
        unreadCountLabel.text = getUnreadCountText(cnt: 0)
        sentTimeLabel.text = "00:00"
        chatBubbleMaxWidth.constant = (Constants.deviceSize.width) * Constants.chatMaxWidthMultiplier
        
        profileButton.layer.cornerRadius = profileButton.frame.height / 2.65
    }
    
    override func prepareForReuse() {
        setDataToDefault()
    }
    
    func setDataToDefault() {
        profileButton.isHidden = false
        nameLabel.isHidden = false
        sentTimeLabel.text = ""
        unreadCountLabel.text = ""
        chatBubbleTextView.text = ""
        chatBubbleTextView.textContainerInset = UIEdgeInsets(top: 5, left: 3, bottom: 5, right: 3)
        chatBubbleTextView.textContainer.lineFragmentPadding = 3
    }
    
    private func getUnreadCountText(cnt: Int) -> String {
        guard cnt > 0 else { return "" }
        
        return String(cnt)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setContent(_ data: Chat) {
        if let cachedImage = ImageManager.shared.imageCache.object(forKey: NSString(string: String(data.chatId))) {
            chatBubbleTextView.textStorage.insert(cachedImage, at: 0)
            chatBubbleTextView.textContainerInset = .zero
            chatBubbleTextView.textContainer.lineFragmentPadding = 0
            
            self.chatBubbleHeight.constant = self.chatBubbleTextView.getTextViewHeight(limit: Constants.chatHeightLimit, gap: self.infoView.frame.width).0
        } else if let appendedImage = UIImage(data: data.image) {
            DispatchQueue.main.async {
                let cachedImage = ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
                
                self.chatBubbleTextView.textStorage.insert(cachedImage, at: 0)
                
                self.chatBubbleHeight.constant = Constants.imageSize
                
                self.chatBubbleTextView.textContainerInset = .zero
                self.chatBubbleTextView.textContainer.lineFragmentPadding = 0
                
                self.chatBubbleHeight.constant = self.systemLayoutSizeFitting(CGSize(width: Constants.imageSize, height: .infinity)).height
            }
        } else {
            chatBubbleTextView.text = data.text
            chatBubbleHeight.constant = chatBubbleTextView.getTextViewHeight(limit: Constants.chatHeightLimit, gap: infoView.frame.width).0
        }
    }
    
    
    func setUserData(_ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool) {
        unreadCountLabel.text = getUnreadCountText(cnt: data.unreadCount)
        sentTimeLabel.text = (
            shouldShowTimeLabel
            ? data.sentTime
            : ""
        )
        
        if shouldShowUserInfo {
            profileButton.setImage(UIImage(named: Constants.defaultImages[data.owner.userId])?.withRenderingMode(.alwaysOriginal), for: .normal)
            nameLabel.text = data.owner.name
        } else {
            profileButton.isHidden = true
            nameLabel.isHidden = true
        }
    }
        
    func setData(_ data: Chat, _ shouldShowTimeLabel: Bool = true , _ shouldShowUserInfo: Bool = true) {
        setDataToDefault()
        
        setContent(data)
        
        setUserData(data, shouldShowTimeLabel, shouldShowUserInfo)
      
    }
    
    deinit{
        print("deinit ChatTableViewCell")
    }
}
