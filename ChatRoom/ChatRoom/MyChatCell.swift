import UIKit

class MyChatCell: UITableViewCell, TableViewCellBase {
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    //    @IBOutlet weak var thumbnailImageView: UIImageView!
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
        // Initialization code
        chatBubbleButton.setTitle("", for: .normal)
        chatBubbleView.layer.cornerRadius = 10
        chatBubbleView.backgroundColor = UIColor(cgColor: Color.Yellow)
//        chatBubbleButton.tintColor = UIColor(cgColor: Color.Black)
        
        unreadCountLabel.text = getUnreadCountText(cnt: 0)
        sentTimeLabel.text = ""
        
        chatBubbleMaxWidth.constant = Constants.deviceSize.width * Constants.chatMaxWidthMultiplier
    }
    
    private func getUnreadCountText(cnt: Int) -> String {
        guard cnt > 0 else { return "" }
        
        return String(cnt)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(_ data: Chat, _ shouldShowTimeLabel: Bool) {
        
        chatBubbleTextView.text = data.text
        
        if let cachedImage = DataStorage.instance.imageCache.object(forKey: NSString(string: String(data.chatId))) {
            chatBubbleTextView.textStorage.insert(cachedImage, at: 0)
        } else if var appendedImage = UIImage(data: data.image) {
            DispatchQueue.main.async {
                let maxSize = Constants.deviceSize.width * Constants.chatMaxWidthMultiplier - 150
                
                appendedImage = appendedImage.resized(to: CGSize(width: maxSize , height: maxSize))
                
                let attachment = NSTextAttachment()
                attachment.image = appendedImage
                let imageString = NSAttributedString(attachment: attachment)
                
                DataStorage.instance.imageCache.setObject(imageString, forKey: NSString(string: String(data.chatId)))
                
                
                self.chatBubbleTextView.textStorage.insert(imageString, at: 0)
                
                self.layoutIfNeeded()
            }
        }
        
        unreadCountLabel.text = getUnreadCountText(cnt: data.unreadCount)
        sentTimeLabel.text = (
            shouldShowTimeLabel
            ? data.sentTime
            : ""
        )
        
        chatBubbleHeight.constant = chatBubbleTextView.getTextViewHeight(limit: Constants.chatHeightLimit, gap: infoView.frame.width).0
//        self.setNeedsLayout()
    }
    
}
