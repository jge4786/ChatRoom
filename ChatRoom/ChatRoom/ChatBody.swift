import UIKit

class ChatBody: UIStackView {
    enum UIOption {
        case shouldHideProfile
        
        case shouldHideName
        
        case shouldHideTime
        
        case isMyChat
    }
    
    @IBOutlet weak var profileWrapperView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var bubbleWrapper: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chatBubbleView: UIView!
    
    @IBOutlet weak var chatBubbleButton: UIButton!
    @IBOutlet weak var chatBubbleTextView: UITextView!
    @IBOutlet weak var opacityFilterView: UIView!
    @IBOutlet weak var chatBubbleHeight: NSLayoutConstraint!
    @IBOutlet weak var chatBubbleMaxWidth: NSLayoutConstraint!
    
    @IBOutlet weak var infoWrapper: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var sentTimeLabel: UILabel!
    
    func setMyChatUI() {
        profileWrapperView.isHidden = true
        nameLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            infoWrapper.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            infoWrapper.trailingAnchor.constraint(equalTo: bubbleWrapper.leadingAnchor),
        ])
    }
    
    func setChatUI(options: UIOption...) -> UIStackView {
        for item in options {
            switch item {
            case .isMyChat:
                print("isMyChat")
            case .shouldHideProfile:
                profileWrapperView.isHidden = true
                print("show")
            case .shouldHideName:
                nameLabel.isHidden = true
                print("name")
            case .shouldHideTime:
                sentTimeLabel.isHidden = true
                print("time")
            @unknown default:
                break
            }
        }
        
        return self
    }
    
    init(_ frame: CGRect) {
        super.init(frame: frame)
        
        chatBubbleMaxWidth.constant = Constants.deviceSize.width * Constants.chatMaxWidthMultiplier
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
