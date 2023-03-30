import UIKit

class MyChatCell: UITableViewCell, TableViewCellBase {
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var opacityFilterView: UIView!
    @IBOutlet weak var chatBubbleHeight: NSLayoutConstraint!
    @IBOutlet weak var chatBubbleView: UIView!
    @IBOutlet weak var chatBubbleButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var sentTimeLabel: UILabel!
    
    @IBOutlet weak var chatBubbleTextView: UITextView!
    
    @IBAction func onTouchInChatBubble(_ sender: Any) {
        print("touchIn")
        manageButtonHighlightAnim(isShow: true)
    }
    
    //버튼 터치 시 실행할 함수 정의
    @IBAction func onTouchOutChatBubble(_ sender: Any) {
        print("touchOut")
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
        
    @IBOutlet weak var chatBubbleMaxWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeData()
    }
    
    
    private func getUnreadCountText(cnt: Int) -> String {
        guard cnt > 0 else { return "" }
        
        return String(cnt)
    }

    
    func initializeData() {
        chatBubbleButton.setTitle("", for: .normal)
        chatBubbleView.layer.cornerRadius = 10
        chatBubbleView.backgroundColor = UIColor(cgColor: Color.Yellow)
        
        unreadCountLabel.text = getUnreadCountText(cnt: 0)
        sentTimeLabel.text = ""
        
        chatBubbleMaxWidth.constant = Constants.deviceSize.width * Constants.chatMaxWidthMultiplier
    }
    
    override func prepareForReuse() {
        setDataToDefault()
    }
    
    func setDataToDefault() {
        chatBubbleTextView.text = ""
        chatBubbleHeight.constant = Constants.imageSize
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setContent(_ data: Chat) {
        if let cachedImage = DataStorage.instance.imageCache.object(forKey: NSString(string: String(data.chatId))) {
            chatBubbleTextView.textStorage.insert(cachedImage, at: 0)
            
            self.chatBubbleHeight.constant = Constants.imageSize
        } else if let appendedImage = UIImage(data: data.image) {
            DispatchQueue.main.async {
                let cachedImage = ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
                
                self.chatBubbleTextView.textStorage.insert(cachedImage, at: 0)
                
                self.chatBubbleHeight.constant = Constants.imageSize
            }
        } else {
            chatBubbleTextView.text = data.text
        }
    }
    
    func setLabel(_ data: Chat, _ shouldShowTimeLabel: Bool) {
        unreadCountLabel.text = getUnreadCountText(cnt: data.unreadCount)
        sentTimeLabel.text = (
            shouldShowTimeLabel
            ? data.sentTime
            : ""
        )
    }
    
    func setData(_ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool = false) {
        setDataToDefault()
        
        
        setContent(data)
        
        setLabel(data, shouldShowTimeLabel)
        
        chatBubbleHeight.constant = chatBubbleTextView.getTextViewHeight(limit: Constants.chatHeightLimit, gap: infoView.frame.width).0
    }
    
}
