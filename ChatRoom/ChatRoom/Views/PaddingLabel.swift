///padding이 적용된 라벨

import UIKit

class PaddingLabel: UILabel {
    let verticalInset: CGFloat = 3.0
    let horizontalInset: CGFloat = 7.0
    
    override func drawText(in rect: CGRect) {
        self.layer.cornerRadius = 8
        let insets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + horizontalInset * 2,
                      height: size.height + verticalInset * 2)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (horizontalInset * 2)
        }
    }
}
