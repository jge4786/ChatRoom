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
        
        let isChatRoom = tabBarController.tabBar.items?.first == tabBarController.tabBar.selectedItem
        
        
        if !isChatRoom {
            nextView.isGPT = true
        } else {
            nextView.isGPT = false
        }
    }
}
