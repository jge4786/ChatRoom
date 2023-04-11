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
        contentTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        safeAreaBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        
        setInitPosition()
        
        addDrawer()
    }
    
    func addDrawer() {
        view.addSubview(drawerView)
        drawerView.addSubview(deleteDataButton)
        
        let drawerWidth = UIScreen.main.bounds.size.width * 0.4
        drawerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(-drawerWidth)
            make.bottom.equalTo(inputTextViewWrapper.snp.top)
            make.width.equalTo(drawerWidth)
        }
        
        deleteDataButton.snp.makeConstraints {
            $0.trailing.leading.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        deleteDataButton.addTarget(self, action: #selector(onPressDeleteDataButton), for: .touchUpInside)
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
        inputTextViewWrapper.layer.borderColor = Color.DarkerGray.cgColor
    }
    
    //헤더 초기화
    private func initHeaderButtonsSetting() {
        self.navigationController?.navigationBar.backgroundColor = Color.DarkerGray

        searchButton.tintColor = Color.White
        
        menuButton.tintColor = Color.White
    }
        
    private func setInitPosition() {
        //하단 버튼의 위치를 고정하기 위한 높이 조절
        
        NSLayoutConstraint.activate([
            self.addImageButton.heightAnchor.constraint(equalToConstant: self.footerWrapperView.frame.height),
            self.sendMessageButton.heightAnchor.constraint(equalToConstant: self.inputTextViewWrapper.frame.height)
        ])
        
        if DataStorage.instance.isGPTRoom(roomId: roomId) {
            addImageButton.snp.remakeConstraints { make in
                make.width.equalTo(10.0)
            }
            addImageButton.isHidden = true
        }
        
        self.fadeDataLoadingScreen()
    }
    
    private func setButtonsUI() {
        addImageButton.setTitle("", for: .normal)
        scrollToBottomButton.setTitle("", for: .normal)
        emojiButton.setTitle("", for: .normal)
        
        scrollToBottomButton.tintColor = Color.LighterBlack
    }
    
    private func fadeDataLoadingScreen() {
        UIView.animate(withDuration: 0.13, delay: 0.2, options: .curveEaseIn) {
            self.dataLoadingScreen.alpha = 0
        } completion: { finished in
            self.dataLoadingScreen.isHidden = true
        }
    }
}


extension ChatRoomViewController {
    private func setData() {
        setRoomSetting()
        loadData()
        loadGPTData()
        registComponents()
        
    }
    
    private func setRoomSetting() {
        roomId = chatRoomInfo.roomId
        
        guard let crData = DataStorage.instance.getChatRoom(roomId: roomId) else {
            fatalError("채팅방 정보 불러오기 실패")
        }
        roomData = crData
        
        self.title = roomData.roomName
        
        guard let uData = DataStorage.instance.getUser(userId: chatRoomInfo.userId) else {
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
