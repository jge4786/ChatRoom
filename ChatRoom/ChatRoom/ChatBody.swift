import UIKit

class ChatBody: UIView {
    enum UIOption {
        case shouldShowProfile
        case hasProfile
        
        case shouldShowName
        
        case shouldShowTime
        
        case isMyChat
    }
    
    var unreadCountLabel: UILabel
    var sentTimeLabel: UILabel
    
    var profileButton: UIButton
    var nameLabel: UILabel
    
    var chatBubbleWrapper: UIView
    var opacityFilter: UIView
    var chatBubbleButton: UIButton
    var chatBubbleText: UITextView
    
    
    init(_ frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
