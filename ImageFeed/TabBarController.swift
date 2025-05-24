import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        UIView.setAnimationsEnabled(false)
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let imagesListPresenter = ImagesListPresenter(view: imagesListViewController)
        imagesListViewController.configure(imagesListPresenter)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title:"",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        
        viewControllers = [imagesListViewController, profileViewController]
    }
}
