import UIKit
extension ChatRoomViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onPressSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func onPressSearchButton() {
        searchIndex = -1
        searchKeyword = searchBar.searchTextField.text ?? ""
        searchResult = searchForKeyword(searchTarget: chatData, key: searchBar.searchTextField.text) ?? []
        
        if searchResult.count == 0 {
            onPressSearchNextButton()
        } else {
            movePrevIndex()
        }
        self.searchBar.resignFirstResponder()
    }
    
    func playSearchAnimaionOnCell(index: Int) {
        if let cell = contentTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ChatTableViewCell {
            cell.playSearchAnimation()
        }
    }
    
    func moveNextIndex() {
        guard searchIndex < searchResult.count - 1 else {
            emojiButton.isEnabled = false
            return
        }
        sendMessageButton.isEnabled = true
        
        searchIndex += 1
                
        let target = searchResult[searchIndex].chatId
        let index = chatData.firstIndex {
           $0.chatId == target
        }

        guard let index = index else { return }
        
        
        contentTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .bottom, animated: false)
        
        playSearchAnimaionOnCell(index: index)
        
    }
    
    func movePrevIndex() {
        guard searchIndex > 0 else  {
            print("asdf")
            sendMessageButton.isEnabled = false
            return
        }
        
        emojiButton.isEnabled = true
        
        searchIndex -= 1
        
        let target = searchResult[searchIndex].chatId
        let index = chatData.firstIndex {
           $0.chatId == target
        }

        guard let index = index else { return }
        
        contentTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .bottom, animated: false)
        
        playSearchAnimaionOnCell(index: index)
    }
    
    @objc
    func onPressSearchNextButton() {
        if searchIndex >= searchResult.count - 2 {
            for _ in 0..<50 {
                onTopReached()
                let result = searchForKeyword(searchTarget: chatData, key: searchKeyword) ?? []

                if result.count > 0 {
                    self.searchResult = result
                    break;
                }
                guard !isEndReached else {
                    movePrevIndex(); // 검색 결과가 없을 경우, 이전 검색 버튼을 비활성화 시키기 위해 추가
                    break
                }
            }

            moveNextIndex()

            return
        } else if searchIndex < searchResult.count - 2 {
            moveNextIndex()
        }
    }
    
    @objc
    func onPressSearchPrevButton() {
        movePrevIndex()
    }
    
    func searchForKeyword(searchTarget: [Chat], key: String?) -> [Chat]? {
        guard let key = key else { return nil }
        
        let result = searchTarget.filter {
            $0.text.contains(key)
        }
        
        return result
    }
    
    @objc
    func handleSearchBar() {
        if searchBar.isHidden {
            goBackButton.image = UIImage(systemName: "magnifyingglass")
            
            navBar.rightBarButtonItems = [menuButton]
            
            menuButton.action = #selector(hideSearchBar)
            menuButton.image = UIImage(systemName: "xmark")
            
            inputTextView.text = ""
            inputTextView.isEditable = false
            inputTextViewHeight.constant = getTextViewHeight()
            
            letterCountWrapperView.isHidden = true
            
            emojiButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            emojiButton.addTarget(self, action: #selector(onPressSearchNextButton), for: .touchUpInside)
            
            sendMessageButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            sendMessageButton.setTitle("", for: .normal)
            sendMessageButton.tintColor = .lightGray
            sendMessageButton.addTarget(self, action: #selector(onPressSearchPrevButton), for: .touchUpInside)
        } else {
            goBackButton.image = UIImage(systemName: "chevron.backward")
            
            
            navBar.rightBarButtonItems = [menuButton, searchButton]
            
            
            menuButton.action = #selector(onPressMenuButton)
            menuButton.image = UIImage(systemName: "ellipsis")
            
            
            inputTextView.isEditable = true
            
            
            emojiButton.setImage(UIImage(systemName: "face.smiling"), for: .normal)
            emojiButton.isEnabled = true
            emojiButton.removeTarget(self, action: nil, for: .allEvents)
            
            sendMessageButton.isEnabled = true
            sendMessageButton.setImage(nil, for: .normal)
            sendMessageButton.setTitle("#", for: .normal)
            sendMessageButton.addTarget(self, action: #selector(onPressSendMessageButton), for: .touchUpInside)
        }
        searchBar.isHidden = !searchBar.isHidden
        
    }
    
    @objc
    func hideSearchBar() {
        print("취소")
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        handleSearchBar()
    }
}
