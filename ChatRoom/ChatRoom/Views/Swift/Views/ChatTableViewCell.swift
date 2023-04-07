import UIKit

class ChatTableViewCell: UITableViewCell, TableViewCellBase {
    var chatId = 0
    weak var delegate: ChangeSceneDelegate?
    let profileSize: CGFloat = 40.0
    
    @IBOutlet weak var chatBubbleHeight: NSLayoutConstraint!

        
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var profileButtonWidth: NSLayoutConstraint!
    
    @objc
    func onTouchInChatBubble() {
        manageButtonHighlightAnim(isShow: true)
    }
    
    //버튼 터치 시 실행할 함수 정의
    @objc
    func onTouchOutChatBubble() {
        delegate?.goToChatDetailScene(chatId: chatId)
        manageButtonHighlightAnim(isShow: false)
    }
    
    @objc
    func onTouchCanceled() {
        manageButtonHighlightAnim(isShow: false)
    }
    
    func manageButtonHighlightAnim(isShow: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
            self.opacityFilterView.layer.opacity = isShow ? 0.3 : 0.0
        }
    }
        
    @IBOutlet weak var infoView: UIView!
//    @IBOutlet weak var chatBubbleMaxWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
    }
    let chatBubbleMaxWidth = (UIScreen.main.bounds.size.width) * Constants.chatMaxWidthMultiplier
    
    let nameLabelFontSize: CGFloat = 13.0
    let infoLabelFontSize: CGFloat = 10.0
    
    var contentStackView = UIStackView()
    
    var profileWrapperView = UIView().then {
        $0.clipsToBounds = true
    }
    var profileButton = UIButton().then {
        $0.setTitle("", for: .normal)
        $0.clipsToBounds = true
    }
    
    var chatStackView = UIStackView().then {
        $0.axis = .vertical
    }
    
    var nameLabel = UILabel().then {
        $0.text = ""
    }
    
    var chatBubbleView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = Color.White
    }
    var chatBubbleButton = UIButton().then {
        $0.setTitle("", for: .normal)
    }
    var opacityFilterView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.opacity = 0
    }
    
    
    // lazy var로 설정한 이유: infoLabelFontSize라는 상수를 UILabel 초기화 과정에서 사용할 수 있도록 하기 위해
    var leftInfoWrapperView = UIView().then {
        $0.accessibilityIdentifier = "leftInfoWrapper"
    }
    lazy var leftUnreadCountLabel = UILabel().then {
        $0.text = ""
        $0.textColor = Color.DarkYellow
        $0.font = UIFont.boldSystemFont(ofSize: infoLabelFontSize)
    }
    lazy var leftSentTimeLabel = UILabel().then {
        $0.text = "00:00"
        $0.textColor = Color.DarkGray
        $0.font = UIFont.systemFont(ofSize: infoLabelFontSize)
    }
    
    var rightInfoWrapperView = UIView()
    lazy var rightUnreadCountLabel = UILabel().then {
        $0.text = ""
        $0.textColor = Color.DarkYellow
        $0.font = UIFont.boldSystemFont(ofSize: infoLabelFontSize)
    }
    
    lazy var rightSentTimeLabel = UILabel().then {
        $0.text = "00:00"
        $0.textColor = Color.DarkGray
        $0.font = UIFont.systemFont(ofSize: infoLabelFontSize)
    }
    
    var unreadCountLabel = UILabel()
    var sentTimeLabel = UILabel()
    
    
    
    func initialize() {
        setSubView()
        setContraint()
        setUIData()
    }
    
    func setSubView() {
        contentWrapperView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(leftInfoWrapperView)
        contentStackView.addArrangedSubview(profileWrapperView)
        contentStackView.addArrangedSubview(chatStackView)
        contentStackView.addArrangedSubview(rightInfoWrapperView)
        
        profileWrapperView.addSubview(profileButton)
        
        chatStackView.addArrangedSubview(nameLabel)
        chatStackView.addArrangedSubview(chatBubbleView)
        
        chatBubbleView.addSubview(chatBubbleButton)
        chatBubbleView.addSubview(opacityFilterView)
        
        
        leftInfoWrapperView.addSubview(leftUnreadCountLabel)
        leftInfoWrapperView.addSubview(leftSentTimeLabel)
        rightInfoWrapperView.addSubview(rightUnreadCountLabel)
        rightInfoWrapperView.addSubview(rightSentTimeLabel)
    }
    
    func setContraint() {
        contentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(3)
        }
        
        profileButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(5)
            $0.height.width.equalTo(profileSize)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        chatBubbleView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.width.lessThanOrEqualTo(chatBubbleMaxWidth)
        }
        
        chatBubbleButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        opacityFilterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        leftInfoWrapperView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        
        rightInfoWrapperView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        leftUnreadCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(3)
            $0.bottom.equalTo(leftSentTimeLabel.snp.top)
        }
        
        leftSentTimeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(3)
        }
        
        rightUnreadCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(3)
            $0.bottom.equalTo(rightSentTimeLabel.snp.top)
        }
        
        rightSentTimeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalTo(rightUnreadCountLabel)
        }

    }
    
    func setUIData() {
        nameLabel.font = nameLabel.font.withSize(nameLabelFontSize)
        
        profileButton.layer.cornerRadius = profileSize / 3.2
        
        chatBubbleButton.addTarget(self, action: #selector(onTouchOutChatBubble), for: .touchUpInside)
        chatBubbleButton.addTarget(self, action: #selector(onTouchCanceled), for: .touchDragExit)
        chatBubbleButton.addTarget(self, action: #selector(onTouchCanceled), for: .touchCancel)
        chatBubbleButton.addTarget(self, action: #selector(onTouchInChatBubble), for: .touchDown)
    }
    
    
    override func prepareForReuse() {
        chatBubbleView.subviews.forEach {
            guard $0 as? UIImageView != nil || $0 as? UITextView != nil else { return }
            
            $0.removeFromSuperview()
        }

        setDataToDefault()
    }
    
    func setDataToDefault(isMyChat: Bool = false) {
        
        switch isMyChat {
        case true:
            contentStackView.snp.remakeConstraints() {
                $0.top.bottom.equalToSuperview().inset(3)
                $0.trailing.equalToSuperview().inset(10)
            }
            
            profileWrapperView.isHidden = true
            nameLabel.isHidden = true
            
            contentStackView.arrangedSubviews.first?.isHidden = false
            contentStackView.arrangedSubviews.last?.isHidden = true
            
            chatBubbleView.backgroundColor = Color.Yellow
            
            unreadCountLabel = leftUnreadCountLabel
            sentTimeLabel = leftSentTimeLabel
            
        case false:
            contentStackView.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview().inset(3)
                $0.leading.equalToSuperview()
            }
            
            profileWrapperView.isHidden = false
            nameLabel.isHidden = false
            
            contentStackView.arrangedSubviews.last?.isHidden = false
            contentStackView.arrangedSubviews.first?.isHidden = true
            
            chatBubbleView.backgroundColor = Color.White
            
            unreadCountLabel = rightUnreadCountLabel
            sentTimeLabel = rightSentTimeLabel
        }
        
        sentTimeLabel.text = ""
        unreadCountLabel.text = ""
    }
    
    private func getUnreadCountText(cnt: Int) -> String {
        guard cnt > 0 else { return "" }
        
        return String(cnt)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

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
                $0.backgroundColor = Color.Transparent
                $0.textColor = .black
                $0.isScrollEnabled = false
                $0.isUserInteractionEnabled = false
                $0.font = UIFont.systemFont(ofSize: 13)
                $0.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
            }
            
            chatBubbleTextView.text = data.text
            
            chatBubbleView.addSubview(chatBubbleTextView)
                       
            chatBubbleTextView.snp.makeConstraints {
                $0.edges.equalTo(chatBubbleView)
            }
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
            let profileImageString = data.owner.profile ?? Constants.defaultImages[data.owner.userId % Constants.defaultImages.count]
            
            profileButton.setImage(UIImage(named: profileImageString)?.withRenderingMode(.alwaysOriginal), for: .normal)
            nameLabel.text = data.owner.name
        } else {
            profileButton.isHidden = true
            nameLabel.isHidden = true
        }
    }
        
    func setData(_ data: Chat, shouldShowTimeLabel: Bool = true , shouldShowUserInfo: Bool = true, isMyChat: Bool = false) {
        setDataToDefault(isMyChat: isMyChat)
        
        setContent(data)
        chatId = data.chatId
        
        setUserData(data, shouldShowTimeLabel, shouldShowUserInfo)
      
    }
}
