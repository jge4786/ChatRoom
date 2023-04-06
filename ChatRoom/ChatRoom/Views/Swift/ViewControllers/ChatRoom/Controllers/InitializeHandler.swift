import UIKit

extension ChatRoomViewController {
    func initializeSettings() {
        setData()
        setUI()
    }
}

// UI
extension ChatRoomViewController {
    
    private func setUI() {
        initHeaderButtonsSetting()
        setButtonsUI()
        
        inputTextViewHeight.constant = getTextViewHeight()
        letterCountLabel.layer.cornerRadius = 8
        
        footerWrapperView.layoutIfNeeded()
        
        initHeaderButtonsSetting()
        initTextView()
        contentTableView.transform = CGAffineTransform(rotationAngle: .pi)
        
        safeAreaBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        
        setInitPosition()

    }
    
    func hidingBar() {
        guard let tabBarController = self.tabBarController,
              let navigationController = self.navigationController
        else {
            return
        }
        
        tabBarController.tabBar.isHidden = true
        navigationController.isNavigationBarHidden = false
    }
    
    private func initTextView() {
        inputTextViewWrapper.layer.cornerRadius = 15
        inputTextViewWrapper.layer.borderWidth = 1
        inputTextViewWrapper.layer.borderColor = Color.DarkerGray
    }
    
    //헤더 초기화
    private func initHeaderButtonsSetting() {
        self.navigationController?.navigationBar.backgroundColor = .darkGray

        searchButton.tintColor = UIColor(cgColor: Color.White)
        
        menuButton.tintColor = UIColor(cgColor: Color.White)
    }
        
    private func setInitPosition() {
        //하단 버튼의 위치를 고정하기 위한 높이 조절
        
        NSLayoutConstraint.activate([
            self.addImageButton.heightAnchor.constraint(equalToConstant: self.footerWrapperView.frame.height),
            self.sendMessageButton.heightAnchor.constraint(equalToConstant: self.inputTextViewWrapper.frame.height)
        ])
        self.fadeDataLoadingScreen()
    }
    
    private func setButtonsUI() {
        addImageButton.setTitle("", for: .normal)
        scrollToBottomButton.setTitle("", for: .normal)
        emojiButton.setTitle("", for: .normal)
        
        scrollToBottomButton.tintColor = UIColor(cgColor: Color.LighterBlack)
    }
    
    private func fadeDataLoadingScreen() {
        UIView.animate(withDuration: 0.13, delay: 0.2, options: .curveEaseIn) {
            self.dataLoadingScreen.layer.opacity = 0
        } completion: { finished in
            self.dataLoadingScreen.isHidden = true
        }
    }
}


extension ChatRoomViewController {
    private func setData() {
        
        //데이터 초기화
        setRoomSetting()
        loadData()
        loadGPTData()
        registComponents()
        
        // ***************디버그, 테스트용*************
        
        userList = DataStorage.instance.getUserList()
//        setSelectUserMenu()
        
        // ****************************************
    }
    
    private func setRoomSetting() {
        roomId = chatRoomInfo.roomId
        me = chatRoomInfo.userId
        selectedUser = me
        
        guard let crData = DataStorage.instance.getChatRoom(roomId: roomId) else {
            fatalError("채팅방 정보 불러오기 실패")
        }
        roomData = crData
        
        self.title = roomData.roomName
        
        guard let uData = DataStorage.instance.getUser(userId: me) else {
            fatalError("유저 정보 불러오기 실패")
        }
        userData = uData
    }
        
    private func registComponents() {
        addKeyboardObserver()
        recognizeHidingKeyboardGesture()
        
        self.inputTextView.delegate = self
        self.contentTableView.delegate = self
        
        ChatTableViewCell.register(tableView: contentTableView)
        MyChatCell.register(tableView: contentTableView)
    }
    
    private func setSelectUserMenu() {
        var menuItems: [UIAction] = []
        
        for idx in 0..<userList.count {
            menuItems.append(
                UIAction(title: userList[idx].name, handler: { [weak self] _ in
                    
                    self?.selectUser(selected: idx)
                })
            )
        }
        
        selectUserButton.menu = UIMenu(title: "사용자 선택",
                                       identifier: nil,
                                       options: .displayInline,
                                       children: menuItems
        )
    }
    
    func loadData() {
        let loadedData = DataStorage.instance.getChatData(roomId: roomId, offset: offset, limit: Constants.chatLoadLimit)
        chatData.append(contentsOf: loadedData)
        
        // 로딩된 데이터가 제한보다 적으면 isEndReached을 true로 하여 로딩 메소드 호출 방지
        guard loadedData.count >= Constants.chatLoadLimit else {
            isEndReached = true
            return
        }
        
        offset += Constants.chatLoadLimit
    }
    
    func loadGPTData() {
        gptInfo = DataStorage.instance.getUser(userId: 0)
    }
}
