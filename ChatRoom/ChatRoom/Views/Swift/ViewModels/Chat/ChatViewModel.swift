import PhotosUI

class ChatViewModel {
    typealias SearchButtonState = (next: Bool, prev: Bool)
    typealias InputButtonHiddenState = (emoji: Bool, message: Bool)
    
    
    var roomId = 0, userData = User()
    var gptInfo = DataStorage.instance.getUser(userId: 0)
    var chatData: Observable<[Chat]> = Observable([])
    var offset = 0
    var dataTask: URLSessionDataTask?
    
    
    //------- ImagePickerController -------
    var configuration: Observable<PHPickerConfiguration?> = Observable(nil)
    var image: Observable<Data?> = Observable(nil)
    
    
    //------- SearchController ------------
    var searchIndex = 0
    var searchResult: [Chat] = []
    var searchKeyword: String = ""
    var searchButtonState: Observable<SearchButtonState> = Observable((next: true, prev: true))
    var targetIndex: Observable<Int?> = Observable(nil)
    
    
    
    //------- TableViewController ---------
    
    
    
    //------- ScrollController ------------
    var isEndReached = false
    
    
    
    //------- InputTextController ---------
    var inputButtonHiddenState: Observable<InputButtonHiddenState> = Observable((emoji: false, message: false))
    
    
    
    //------- InitializeHandler -----------
    func setRoomInfo(roomId: Int, userData: User) {
        self.roomId = roomId
        self.userData = userData
    }
    func loadData() {
        guard !isEndReached else { return }
        
        let loadedData = DataStorage.instance.getChatData(roomId: roomId, offset: offset, limit: Constants.chatLoadLimit)

        chatData.value.append(contentsOf: loadedData)
        
        guard loadedData.count >= Constants.chatLoadLimit else {
            isEndReached = true
            return
        }
        
        offset += Constants.chatLoadLimit
    }
    
    func handleDeinitProcess() {
        cancelGPTRequest()
        saveData()
    }
    
    private func saveData() {
        DataStorage.instance.saveData()
    }
    
    private func cancelGPTRequest() {
        if let dataTask = dataTask,
           chatData.value.first?.text == "..."
        {
            let canceledMessage = "취소된 요청입니다."
            
            if let firstIndex = chatData.value.first?.chatId {
                _ = DataStorage.instance.appendGptChatData(dataSetId: self.roomId, message: Message(role: "error", content: canceledMessage))
                _ = DataStorage.instance.updateChatData(roomId: roomId, chatId: firstIndex, text: canceledMessage)
            }
            
            dataTask.cancel()
        }
        
    }
}

//ImagePickerConteroller
extension ChatViewModel {
    func openPhotoLibrary () {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        
        self.configuration.value = configuration
    }
    
    func onPicker(provider: NSItemProvider?) {
        if let itemProvider = provider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage,
                          let imageData = image.pngData()
                    else {
                        return
                    }
                    self.image.value = imageData
                                        
                    let cachedImage = DataStorage.instance.appendChatData(roomId: self.roomId,
                                                                          owner: self.userData,
                                                                          image: imageData)
                    
                    self.chatData.value.insert(cachedImage, at: 0)
                }
            }
        }
    }
}

//------ SearchController ----------
extension ChatViewModel {
    
    func onPressSearchNextButton() {
        print("야호")
        if searchIndex >= searchResult.count - 2 {
            for _ in 0..<50 {
                loadData()
                let result = searchForKeyword(searchTarget: chatData.value, key: searchKeyword)

                if result.count > 0 {
                    self.searchResult = result
                    break;
                }
                guard !isEndReached else {
                    searchPrevData(); // 검색 결과가 없을 경우, 이전 검색 버튼을 비활성화 시키기 위해 추가
                    break
                }
            }

            searchNextData()

            return
        } else if searchIndex < searchResult.count - 2 {
            searchNextData()
        }
    }
    
    func startSearch(keyword: String) {
        searchIndex = -1
        searchKeyword = keyword // 빈 텍스트일 경우 검색 결과 없음으로 나오므로 기본값 설정
        searchResult = searchForKeyword(searchTarget: chatData.value, key: keyword)
        
        searchButtonState.value = (true, true)
        
        if searchResult.count == 0 {
            onPressSearchNextButton()
        } else {
            searchPrevData()
        }
    }
    
    func searchForKeyword(searchTarget: [Chat], key: String?) -> [Chat] {
        guard let key = key else { return [] }
        
        let result = searchTarget.filter {
            $0.text.contains(key)
        }
        
        return result
    }
    
    func moveToNextIndex() {
        guard searchIndex < searchResult.count - 1 else {
            searchButtonState.value.next = false
            return
        }
        searchButtonState.value.prev = true
        
        searchIndex += 1
        
        let target = searchResult[searchIndex].chatId
        let index = chatData.value.firstIndex {
           $0.chatId == target
        }

        guard let index = index else { return }
        
        targetIndex.value = index
    }
    
    func moveToPrevIndex() {
        guard searchIndex > 0 else  {
            searchButtonState.value.prev = false
            return
        }
        searchButtonState.value.next = true
        
        searchIndex -= 1
        
        let target = searchResult[searchIndex].chatId
        let index = chatData.value.firstIndex {
           $0.chatId == target
        }

        guard let index = index else { return }
        
        targetIndex.value = index
    }
    
    
    func searchNextData() {
        moveToNextIndex()
    }
    
    func searchPrevData() {
        moveToPrevIndex()
    }
}




//-------- ScrollController
extension ChatViewModel {
    func loadMore() { }
}


//-------- TableViewController ----------
extension ChatViewModel {
    func numberOfRowsInSection() -> Int {
        return chatData.value.count
    }
    
    func prefetchRowsAt(index: Int) {
        let data = chatData.value[index]
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
    
//    func setCellData(_ uid: Int, _ data: Chat, _ shouldShowTimeLabel: Bool, _ shouldShowUserInfo: Bool) -> UITableViewCell {
//        
//        guard let cell = ChatTableViewCell.dequeueReusableCell(tableView: contentTableView) else {
//            return UITableViewCell()
//        }
//        
//        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
//        cell.delegate = self
//        
//        cell.setData(
//            data,
//            shouldShowTimeLabel: shouldShowTimeLabel,
//            shouldShowUserInfo: shouldShowUserInfo,
//            isMyChat: uid == userData.userId)
//        
//        return cell
//    }
//    
//    
//    func cellForRowAt(indexPath: IndexPath) {
//        let curData = chatData[indexPath.row]
//        let uid = curData.owner.userId
//        
//        //데이터가 하나일 경우 indexPath.row > 0을 통과하지 못하기 때문에 추가한 조건
//        guard chatData.count != 1 else { return setCellData(uid, curData, true, true) }
//        
//        
//        //이전 데이터와 같은 시간에 작성된 채팅인지 확인
//        guard indexPath.row > 0,
//              case let prevData = chatData[indexPath.row - 1]
//        else {
//            let shouldShowUserInfo = uid != chatData[indexPath.row + 1].owner.userId
//            
//            return setCellData(uid, curData, true, shouldShowUserInfo)
//        }
//
//        let shouldShowTimeLabel = (uid != prevData.owner.userId || curData.sentTime != prevData.sentTime)
//
//        
//        //다음 데이터와 작성자가 같은지 확인
//        guard indexPath.row + 1 < chatData.count,
//              case let nextData = chatData[indexPath.row + 1]
//        else {
//            return setCellData(uid, curData, shouldShowTimeLabel, true)
//        }
//
//        let shouldShowUserInfo = uid != nextData.owner.userId
//        
//        return setCellData(uid, curData, shouldShowTimeLabel, shouldShowUserInfo)
//    }
}






//-------- InputTextController
extension ChatViewModel {
    func isMessageEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func sendMessage(owner: User, text: String, isUser: Bool = true) {
        if isMessageEmpty(text) { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
        chatData.value.insert( DataStorage.instance.appendChatData(roomId: roomId, owner: owner, text: text), at: 0)
    }
    
    // 챗GPT의 메세지 업데이트
    func updateLatestMessage(text: String) {
        guard let firstIndex = chatData.value.first?.chatId else { return }
        _ = DataStorage.instance.updateChatData(roomId: roomId, chatId: firstIndex, text: text)
        
        guard chatData.value.first != nil else { return }
        chatData.value[0].text = text
    }
    
    
    
    func sendMessageToGPT(text: String) {
        if isMessageEmpty(text) { return }

        sendMessage(owner: userData, text: text)
        
        var gptDataSet = DataStorage.instance.getGptDataSet(dataSetId: roomId)
        
        if gptDataSet == nil {
            gptDataSet = []
        }
        
        let requestedMessage = Message(role: "user", content: text)
        
        gptDataSet?.append( DataStorage.instance.appendGptChatData(dataSetId: roomId, message: requestedMessage) )
        
        guard let gptDataSet = gptDataSet else { return }
        
        sendMessage(owner: self.gptInfo!, text: "...", isUser: false)
        
        inputButtonHiddenState.value.message = true
        dataTask = APIService.shared.sendChat(text: gptDataSet) { [weak self] response in
            guard let self = self else { return }
            _ = DataStorage.instance.appendGptChatData(dataSetId: self.roomId, message: response)
            self.updateLatestMessage(text: response.content)
            self.inputButtonHiddenState.value.message = false
        }
    }
}







extension ChatViewModel {}
extension ChatViewModel {}
