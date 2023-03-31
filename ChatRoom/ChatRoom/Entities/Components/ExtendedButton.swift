///터치 영역을 확장할 수 있는 버튼

import UIKit

class ExtendedButton: UIButton {

    @IBInspectable var verticalHitSlop: Double = 0.0
    @IBInspectable var horizontalHitSlop: Double = 0.0
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        
        let touchArea = bounds.insetBy(dx: -horizontalHitSlop , dy: -verticalHitSlop)
        
        return touchArea.contains(point)
    }
}
