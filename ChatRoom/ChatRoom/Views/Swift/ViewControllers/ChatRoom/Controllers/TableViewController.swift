//
//  TableViewController.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/31.
//

import UIKit

//테이블 뷰 초기화
extension ChatRoomViewController:  UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching{
    func scrollToBottom() {
        guard chatData.count >= 0 else { return }
//        contentTableView.setContentOffset(.zero, animated: false)

//        let tmp = contentTableView.decelerationRate
//        contentTableView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
//        contentTableView.decelerationRate = tmp
        self.contentTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        scrollToBottomButton.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    private func prefetchData(index: Int) {
        let data = chatData[index]
        DispatchQueue.main.async {
            if let appendedImage = UIImage(data: data.image) {
                guard ImageManager.shared.imageCache.object(forKey: NSString(string: String(data.chatId))) == nil else {
                    return
                }

                let cachedImage = ImageManager.shared.saveImageToCache(image: appendedImage, id: data.chatId)
                
                ImageManager.shared.imageCache.setObject(cachedImage, forKey: NSString(string: String(data.chatId)))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            prefetchData(index: indexPath.row)
        }
    }
    
    func setCellData(_ uid: Int, _ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool) -> UITableViewCell {
        if uid != me {
            guard let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
                return UITableViewCell()
            }
            cell.transform = CGAffineTransform(rotationAngle: .pi)
            cell.delegate = self
            
            cell.setData(data, shouldShowTimeLabel, shouldShowUserInfo)
            
            return cell
        }else{
            guard let cell = MyChatCell.dequeueReusableCell(tableView: contentTableView) else {
                return UITableViewCell()
            }
            cell.transform = CGAffineTransform(rotationAngle: .pi)
            
            cell.delegate = self
            
            cell.setData(data, shouldShowTimeLabel, shouldShowUserInfo)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let curData = chatData[indexPath.row]
        let uid = curData.owner.userId
        
        // 시간 표시는 처음 채팅에, 프로필 표시는 마지막 채팅에

        guard chatData.count != 1 else { return setCellData(uid, curData, true, true) }
        
        guard indexPath.row > 0,
              case let prevData = chatData[indexPath.row - 1]
        else {
            let shouldShowUserInfo = uid != chatData[indexPath.row + 1].owner.userId
            
            return setCellData(uid, curData, true, shouldShowUserInfo)
        }

        let shouldShowTimeLabel = (uid != prevData.owner.userId || curData.sentTime != prevData.sentTime)

        guard indexPath.row + 1 < chatData.count,
              case let nextData = chatData[indexPath.row + 1]
        else {
            return setCellData(uid, curData, shouldShowTimeLabel, true)
        }

        let shouldShowUserInfo = uid != nextData.owner.userId

        
        return setCellData(uid, curData, shouldShowTimeLabel, shouldShowUserInfo)
    }
}

