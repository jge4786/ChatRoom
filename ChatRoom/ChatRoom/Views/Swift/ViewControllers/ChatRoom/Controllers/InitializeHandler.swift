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
        
        setSubView()
        setContraints()
        
        addActionTarget()
    }
    
    private func addRoomButton(key: Int) {
        let button = UIButton().then {
            $0.backgroundColor = Color.Black
            $0.tag = key
            $0.setTitle("GPT \(key)", for: .normal)
        }
        
        drawerRoomStackView.addArrangedSubview(button)
    }
    
    private func setRoomList() {
        let roomList = DataStorage.instance.getGptDataSetList()
        
        roomList.sorted {
            $0.key < $1.key
        }.forEach {
            addRoomButton(key: $0.key)
        }
    }
    
    private func setSubView() {
        view.addSubview(contentBlurView)
        view.addSubview(drawerView)
                
        inputTextViewWrapper.addSubview(messageLoadingIndicator)
        
        drawerView.addSubview(drawerRoomScrollView)
        drawerView.addSubview(deleteDataButton)
        
        drawerRoomScrollView.addSubview(drawerRoomStackView)
        setRoomList()
    }
    
    private func setContraints() {
        NSLayoutConstraint.activate([
            self.addImageButton.heightAnchor.constraint(equalToConstant: self.footerWrapperView.frame.height),
            self.sendMessageButton.heightAnchor.constraint(equalToConstant: self.inputTextViewWrapper.frame.height)
        ])
        
        messageLoadingIndicator.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalTo(sendMessageButton)
        }
        
        // GPT 채팅방일 경우, 이미지 추가 버튼 숨김.
        if DataStorage.instance.isGPTRoom(roomId: roomId) {
            addImageButton.snp.remakeConstraints { make in
                make.width.equalTo(10.0)
            }
            addImageButton.isHidden = true
        }
        
        contentBlurView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        let drawerWidth = UIScreen.main.bounds.size.width * 0.7
        drawerView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(-drawerWidth)
            make.width.equalTo(drawerWidth)
        }
        
        drawerRoomScrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(deleteDataButton.snp.top).inset(10)
        }
        
        drawerRoomStackView.snp.makeConstraints {
            $0.top.bottom.width.equalToSuperview()
        }
        
        drawerRoomStackView.subviews.forEach {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(40)
            }
        }
        
        deleteDataButton.snp.makeConstraints {
            $0.trailing.leading.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
    
    func addActionTarget() {
        deleteDataButton.addTarget(self, action: #selector(onPressDeleteDataButton), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer (
            target: self, action: #selector(onPressMenuButton)
        )
        
        contentBlurView.addGestureRecognizer(tap)
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
        
    private func setButtonsUI() {
        addImageButton.setTitle("", for: .normal)
        scrollToBottomButton.setTitle("", for: .normal)
        emojiButton.setTitle("", for: .normal)
        
        scrollToBottomButton.tintColor = Color.LighterBlack
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

    @discardableResult
    func loadData() -> [Chat]? {
        let loadedData = DataStorage.instance.getChatData(roomId: roomId, offset: offset, limit: Constants.chatLoadLimit)
        chatData.append(contentsOf: loadedData)
        
        // 로딩된 데이터가 제한보다 적으면 isEndReached을 true로 하여 로딩 메소드 호출 방지
        guard loadedData.count >= Constants.chatLoadLimit else {
            isEndReached = true
            return nil
        }
        
        offset += Constants.chatLoadLimit
        
        return loadedData
    }
    
    func loadGPTData() {
        gptInfo = DataStorage.instance.getUser(userId: 0)
    }
}
