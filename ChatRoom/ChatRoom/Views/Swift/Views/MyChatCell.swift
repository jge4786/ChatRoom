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
    
    @IBOutlet weak var chatBubbleTextView: UITextView!
    
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
        
//        viewModel.opacityView.bind { [weak self] view in
//            self?.opacityFilterView = view
//        }
//
//        viewModel.chatBubbleHeight.bind { [weak self] height in
//            self?.chatBubbleHeight = height
//        }
//
//        viewModel.chatBubbleView.bind { [weak self] view in
//            self?.chatBubbleView = view
//        }
//
//        viewModel.chatBubbleButton.bind { [weak self] btn in
//            self?.chatBubbleButton = btn
//        }
//
//        viewModel.unreadCountLabel.bind { [weak self] label in
//            self?.unreadCountLabel = label
//        }
//
//        viewModel.sentTimeLabel.bind { [weak self] label in
//            self?.sentTimeLabel = label
//        }
//
//        viewModel.chatBubbleTextView.bind { [weak self] text in
//            self?.chatBubbleTextView = text
//        }
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
        chatBubbleTextView.textContainerInset = UIEdgeInsets(top: 5, left: 3, bottom: 5, right: 3)
        chatBubbleTextView.textContainer.lineFragmentPadding = 3
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setHeight(height: CGFloat) {
        chatBubbleHeight.constant = height
    }
    
    @IBOutlet weak var tmpImageView: UIImageView!
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
        
        chatId = data.chatId
        
        setContent(data)
        
        setLabel(data, shouldShowTimeLabel)
    }
}
