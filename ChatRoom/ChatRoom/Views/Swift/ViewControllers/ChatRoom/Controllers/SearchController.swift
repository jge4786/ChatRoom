import UIKit
extension ChatRoomViewController: UISearchBarDelegate {
    // 검색 버튼 클릭
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onPressSearchButton()
    }
    
    // 검색 취소 버튼 클릭
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    // 검색 시작
    func onPressSearchButton() {
        chatViewModel.startSearch(keyword: searchBar.searchTextField.text ?? "")
        
        self.searchBar.resignFirstResponder()
    }
    
    func playSearchAnimaionOnCell(index: Int) {
        if let cell = contentTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ChatTableViewCell {
            cell.playSearchAnimation()
        }
    }
    
    @objc
    func onPressSearchNextButton() {
        chatViewModel.searchNextData()
    }
    
    @objc
    func onPressSearchPrevButton() {
        chatViewModel.searchPrevData()
    }
    
    func searchForKeyword(searchTarget: [Chat], key: String?) -> [Chat] {
        guard let key = key else { return [] }
        
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
