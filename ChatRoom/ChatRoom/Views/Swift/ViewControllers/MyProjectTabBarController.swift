import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class MyProjectTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if let controllers = self.tabBarController?.viewControllers {
            controllers.forEach {
                $0.tabBarItem.image = nil
            }
        }
    }
}

extension MyProjectTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let nav = viewController as? UINavigationController,
              let nextView = nav.viewControllers.first as? ChatRoomListController
        else { return }
        
        guard let selectedItem = tabBarController.tabBar.selectedItem,
              let firstIndex = tabBarController.tabBar.items?.firstIndex(of: selectedItem)
        else {
            nextView.tabId = .normal
            return
        }
        
        switch firstIndex {
        case 0:
            nextView.tabId = .normal
        case 1:
            nextView.tabId = .gpt
        default:
            nextView.tabId = .normal
        }
    }
}

//TODO: Enum 위치 변경
enum TabBarIdentifier {
    case normal
    case gpt
}
