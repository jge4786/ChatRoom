import UIKit

extension UITextView {
    func getTextViewSize(gap: CGFloat = 0 ) -> CGSize {
        let size = CGSize(width: (Constants.deviceSize.width - gap) * Constants.chatMaxWidthMultiplier, height: .infinity)
        
        let estimatedSize = sizeThatFits(size)
        
        
        return estimatedSize
    }
    
    func getTextViewHeight(limit: Int = 0, gap: CGFloat = 0) -> (Double, Bool) {
        guard numberOfLines(gap: gap) > 0 && numberOfLines(gap: gap) <= limit + 1 else {
            return (Double(font!.lineHeight) * Double(limit + 1), false)
        }
        
        return (getTextViewSize(gap: gap).height, true)
    }
        
    func numberOfLines(gap: CGFloat = 0) -> Int {
        let size = getTextViewSize(gap: gap)
        
        return Int(size.height / font!.lineHeight)
    }
}
