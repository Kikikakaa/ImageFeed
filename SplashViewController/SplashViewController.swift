import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SplashViewController: viewDidLoad вызван")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SplashViewController: viewDidAppear вызван")
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            // Show Auth Screen
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                // После успешного получения токена, загружаем профиль
                guard let token = self.oauth2TokenStorage.token else {
                    return
                }
                self.fetchProfile(token: token)
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        print("🔄 [Splash] Запуск fetchProfile с токеном: \(token)")
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfileInfo(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            print("🔄 [Splash] Получен ответ от fetchProfileInfo")
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileService.shared.updateProfile(profile)
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    print("🔄 [Splash] Получен ответ от fetchProfileImageURL")
                    switch imageResult {
                    case .success(let avatarURL):
                        ProfileImageService.shared.updateAvatarURL(avatarURL)
                        print("Аватарка загружена: \(avatarURL)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.switchToTabBarController()
                        }
                    case .failure(let error):
                        print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.switchToTabBarController()
                        }
                    }
                }
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription, token: token)
            }
        }
    }
    
    private func showErrorAlert(message: String, token: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchProfile(token: token)
        }
        alert.addAction(retryAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
