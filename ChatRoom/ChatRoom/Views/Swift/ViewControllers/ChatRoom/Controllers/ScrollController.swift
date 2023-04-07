import UIKit

extension ChatRoomViewController: UIScrollViewDelegate {
    func onTopReached() {
        guard !isLoading,
              !isEndReached
        else { return }
        
        isLoading = true
        
        //연속 로딩 방지
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1 ) {
            self.isLoading = false
        }
        
        self.loadData()
        self.contentTableView.reloadData()
    }
    
    // 스크롤 버튼 표시 관리
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        let offsetValue = scrollView.contentOffset.y
        
        // 텍스트뷰 이벤트에 반응하는 것 방지
        if scrollView.restorationIdentifier != nil {
            return
        }
        
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            onTopReached()
        }
        
        if velocity >= 0 && offsetValue > Constants.deviceSize.height && scrollToBottomButton.isHidden {
            scrollToBottomButton.isHidden = false
        } else if velocity <= 0 && offsetValue < 10 && scrollView.isDecelerating && !scrollToBottomButton.isHidden {
            scrollToBottomButton.isHidden = true
        }
    }
}
