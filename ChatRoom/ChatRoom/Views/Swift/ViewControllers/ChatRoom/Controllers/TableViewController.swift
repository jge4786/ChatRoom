import UIKit

//테이블 뷰 초기화
extension ChatRoomViewController:  UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching{
    func scrollToBottom() {
        view.layoutIfNeeded()
        guard chatData.count >= 0 else { return }
        contentTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        print("테이블뷰 \(contentTableView.contentOffset.y)")
        contentTableView.contentOffset.y = 0
        contentTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        print("끝 \(contentTableView.contentOffset.y)")
        
        scrollToBottomButton.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    private func prefetchData(index: Int) {
        let data = chatData[index]
        DispatchQueue.main.async {
            if let appendedImage = UIImage(data: data.image) {
                guard ImageManager.shared.imageDataCache.object(forKey: NSString(string: String(data.chatId))) == nil else {
                    return
                }

                let cachedImage = ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
                
                ImageManager.shared.imageDataCache.setObject(cachedImage, forKey: NSString(string: String(data.chatId)))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            prefetchData(index: indexPath.row)
        }
    }
    
    func setCellData(_ uid: Int, _ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool) -> UITableViewCell {
        
        guard let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
            return UITableViewCell()
        }
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.delegate = self
        
        cell.setData(
            data,
            shouldShowTimeLabel: shouldShowTimeLabel,
            shouldShowUserInfo: shouldShowUserInfo,
            isMyChat: uid == userData.userId)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let curData = chatData[indexPath.row]
        let uid = curData.owner.userId
        
        //데이터가 하나일 경우 indexPath.row > 0을 통과하지 못하기 때문에 추가한 조건
        guard chatData.count != 1 else { return setCellData(uid, curData, true, true) }
        
        
        //이전 데이터와 같은 시간에 작성된 채팅인지 확인
        guard indexPath.row > 0,
              case let prevData = chatData[indexPath.row - 1]
        else {
            let shouldShowUserInfo = uid != chatData[indexPath.row + 1].owner.userId
            
            return setCellData(uid, curData, true, shouldShowUserInfo)
        }

        let shouldShowTimeLabel = (uid != prevData.owner.userId || curData.sentTime != prevData.sentTime)

        
        //다음 데이터와 작성자가 같은지 확인
        guard indexPath.row + 1 < chatData.count,
              case let nextData = chatData[indexPath.row + 1]
        else {
            return setCellData(uid, curData, shouldShowTimeLabel, true)
        }

        let shouldShowUserInfo = uid != nextData.owner.userId
        
        return setCellData(uid, curData, shouldShowTimeLabel, shouldShowUserInfo)
    }
}

