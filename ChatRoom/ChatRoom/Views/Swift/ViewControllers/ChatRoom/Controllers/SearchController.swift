import UIKit
extension ChatRoomViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            print("시작")
            self.searchBar.showsCancelButton = true
            
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            print("뭐임")
        }
        
        // 서치바에서 검색버튼을 눌렀을 때 호출
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("눌름")
        }
        
        // 서치바에서 취소 버튼을 눌렀을 때 호출
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            print("취소")
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
        }
}
