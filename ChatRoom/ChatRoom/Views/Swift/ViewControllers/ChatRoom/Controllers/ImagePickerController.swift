import PhotosUI

extension ViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate  {
    func openPhotoLibrary() {
        var configuration = PHPickerConfiguration()
        
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           picker.dismiss(animated: true) // 1
           
           let itemProvider = results.first?.itemProvider // 2
           
           if let itemProvider = itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
               itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
                   DispatchQueue.main.async {
                       guard let image = image as? UIImage,
                             let imageData = image.pngData()
                       else {
                           return
                       }
                       
                       self.chatData.insert( DataStorage.instance.appendChatData(roomId: self.roomId, owner: self.userList[self.selectedUser], image: imageData), at: 0)
                       
                       self.scrollToBottom()
                       picker.dismiss(animated: true)
                       
                   }
               }
           } else {
               // TODO: Handle empty results or item provider not being able load UIImage
           }
       }

}
