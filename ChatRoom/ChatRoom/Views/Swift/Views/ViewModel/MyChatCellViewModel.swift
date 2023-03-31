import UIKit

class MyChatCellViewModel {
    
    let opacityView: Observable<UIView?> = Observable(nil)
//    let chatBubbleHeight: Observable< NSLayoutConstraint?> = Observable(nil)
//    let chatBubbleView: Observable< UIView?> = Observable(nil)
//    let chatBubbleButton: Observable< UIButton?> = Observable(nil)
//    let unreadCountLabel: Observable< UILabel?> = Observable(nil)
//    let sentTimeLabel: Observable< UILabel?> = Observable(nil)
//    let chatBubbleTextView: Observable<UITextView?> = Observable(nil)
//    let infoView: Observable<UIView?> = Observable(nil)
    
//    func setDataToDefault() {
//        chatBubbleTextView.value?.text = ""
//        chatBubbleHeight.value?.constant = Constants.imageSize
//        chatBubbleTextView.value?.textContainerInset = UIEdgeInsets(top: 5, left: 3, bottom: 5, right: 3)
//        chatBubbleTextView.value?.textContainer.lineFragmentPadding = 3
//    }
//
//    func setHeight(height: CGFloat) {
//        chatBubbleHeight.value?.constant = height
//    }
//
//
//
//    private func getUnreadCountText(cnt: Int) -> String {
//        guard cnt > 0 else { return "" }
//
//        return String(cnt)
//    }

    
//    func setContent(_ data: Chat) {
//        if let cachedImage = ImageManager.shared.imageCache.object(forKey: NSString(string: String(data.chatId))) {
//            chatBubbleTextView.value?.textStorage.insert(cachedImage, at: 0)
//            chatBubbleTextView.value?.textContainerInset = .zero
//            chatBubbleTextView.value?.textContainer.lineFragmentPadding = 0
//            self.chatBubbleHeight.value?.constant = self.chatBubbleTextView.value?.getTextViewHeight(limit: Constants.chatHeightLimit, gap: self.infoView.value?.frame.width).0
//        } else if let appendedImage = UIImage(data: data.image) {
//            DispatchQueue.main.async {
//                let cachedImage = ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
//                
//                self.chatBubbleTextView.value?.textStorage.insert(cachedImage, at: 0)
//                
//                self.chatBubbleHeight.value?.constant = Constants.imageSize
//                
//                self.chatBubbleTextView.value?.textContainerInset = .zero
//                self.chatBubbleTextView.value?.textContainer.lineFragmentPadding = 0
//                
//                self.chatBubbleHeight.value?.constant = self.systemLayoutSizeFitting(CGSize(width: Constants.imageSize, height: .infinity)).height
//            }
//        } else {
//            chatBubbleTextView.value?.text = data.text
//            chatBubbleHeight.value?.constant = chatBubbleTextView.value?.getTextViewHeight(limit: Constants.chatHeightLimit, gap: infoView.value?.frame.width).0
//        }
//    }
//    
//    func setLabel(_ data: Chat, _ shouldShowTimeLabel: Bool) {
//        unreadCountLabel.value?.text = getUnreadCountText(cnt: data.unreadCount)
//        sentTimeLabel.value?.text = (
//            shouldShowTimeLabel
//            ? data.sentTime
//            : ""
//        )
//    }
//    
//    func setData(_ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool = false) {
//        setDataToDefault()
//        
//        chatId = data.chatId
//        
//        setContent(data)
//        
//        setLabel(data, shouldShowTimeLabel)
//    }
//    
    func manageButtonHighlightAnim(isShow: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
            self.opacityView.value?.layer.opacity = isShow ? 0.3 : 0.0
        }
    }
}
