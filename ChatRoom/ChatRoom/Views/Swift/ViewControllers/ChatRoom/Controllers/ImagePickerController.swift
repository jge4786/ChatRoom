import PhotosUI

extension ChatRoomViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate  {
    func openPhotoLibrary() {
        var configuration = PHPickerConfiguration()
        
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           picker.dismiss(animated: true)
           
           let itemProvider = results.first?.itemProvider
           
           if let itemProvider = itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) {
               itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                   DispatchQueue.main.async {
                       guard let image = image as? UIImage,
                             let imageData = image.pngData()
                       else {
                           return
                       }
                       
                       let cachedImage = DataStorage.instance.appendChatData(roomId: self.roomId,
                                                                             owner: self.userData,
                                                                             image: imageData)
                       
                       self.chatData.insert(cachedImage, at: 0)
                       
                       self.scrollToBottom()
                       picker.dismiss(animated: true)
                       
                   }
               }
           }
       }

}
