import UIKit

extension ViewController: UIScrollViewDelegate {
    func onTopReached() {
        print("loading!")
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
            self.loadData()
            
            self.contentTableView.reloadData()
            
            self.isLoading = false
        }
    }
    
    
    // 스크롤 버튼 표시 관리
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        
        let offsetValue = scrollView.contentSize.height - (scrollView.bounds.size.height + scrollView.contentOffset.y)
        
        // 텍스트뷰 이벤트에 반응하는 것 방지
        if scrollView.restorationIdentifier != nil {
            return
        }
        if scrollView.contentOffset.y < Constants.loadThreshold && !isLoading && !isEndReached {
            onTopReached()
        }
        
        ///velocity: 양수일 경우 위로 스크롤 중
        ///offsetValue: 스크롤뷰의 가장 아래서부터의 contentOffset 값
        if velocity >= 0 && offsetValue > Constants.deviceSize.height && scrollToBottomButton.isHidden {
            scrollToBottomButton.isHidden = false
        }else if velocity <= 0 && offsetValue < 10 && scrollView.isDecelerating && !scrollToBottomButton.isHidden {
            scrollToBottomButton.isHidden = true
        }
    }
}
