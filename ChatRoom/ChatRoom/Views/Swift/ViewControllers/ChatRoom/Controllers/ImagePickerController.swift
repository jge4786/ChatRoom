import PhotosUI

extension ChatRoomViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate  {
    func openPhotoLibrary() {
        chatViewModel.openPhotoLibrary()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        chatViewModel.onPicker(provider: results.first?.itemProvider)
    }
}
