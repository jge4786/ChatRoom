import UIKit

class MyChatCell: UITableViewCell, TableViewCellBase {
    var chatId = 0
    weak var delegate: ChangeSceneDelegate?
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var opacityFilterView: UIView!
    @IBOutlet weak var chatBubbleHeight: NSLayoutConstraint!
    @IBOutlet weak var chatBubbleView: UIView!
    @IBOutlet weak var chatBubbleButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var sentTimeLabel: UILabel!
        
    
    @IBAction func onTouchInChatBubble(_ sender: Any) {
        print("touchIn")
        manageButtonHighlightAnim(isShow: true)
    }
    
    //버튼 터치 시 실행할 함수 정의
    @IBAction func onTouchOutChatBubble(_ sender: Any) {
        print("touchOut")
        delegate?.goToChatDetailScene(chatId: chatId)
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
        
        chatBubbleMaxWidth.constant = UIScreen.main.bounds.size.width * Constants.chatMaxWidthMultiplier
    }
    
    override func prepareForReuse() {
        chatBubbleView.subviews.forEach {
            guard $0 as? UIImageView != nil || $0 as? UITextView != nil else { return }
            
            $0.removeFromSuperview()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setHeight(height: CGFloat) {
        chatBubbleHeight.constant = height
    }
    
    @IBOutlet weak var tmpImageView: UIImageView!
    func setContent(_ data: Chat) {
        if let cachedImage = ImageManager.shared.imageDataCache.object(forKey: NSString(string: String(data.chatId))) {
            let tmpImage = UIImageView(image: cachedImage)
            
            self.chatBubbleView.addSubview(tmpImage)
            
            tmpImage.snp.makeConstraints {
                $0.edges.equalTo(chatBubbleView)
            }
            
        } else if let appendedImage = UIImage(data: data.image) {
            let imageView = UIImageView(image: ImageManager.shared.resized(image: appendedImage, to: ImageManager.shared.getFitSize(image: appendedImage)))
            
            chatBubbleView.addSubview(imageView)
            
            imageView.snp.makeConstraints {
                $0.edges.equalTo(chatBubbleView)
            }
            DispatchQueue.main.async {
                ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
            }
        } else {
            let chatBubbleTextView = UITextView().then {
                $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                $0.textColor = .black
                $0.isScrollEnabled = false
                $0.isUserInteractionEnabled = false
            }
            
            chatBubbleTextView.text = data.text
            
            chatBubbleView.addSubview(chatBubbleTextView)
                       
            chatBubbleTextView.snp.makeConstraints {
                $0.edges.equalTo(chatBubbleView)
            }
            
            
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
    
    func setData(_ data: Chat, shouldShowTimeLabel: Bool, shouldShowUserInfo: Bool = false) {
        chatId = data.chatId
        
        setContent(data)
        
        setLabel(data, shouldShowTimeLabel)
    }
}
