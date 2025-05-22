import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate? 
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
        self.isModalInPresentation = true
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                print("[Auth] Успешная аутентификация. Токен: \(token)")
                OAuth2TokenStorage.shared.token = token
                print("[Auth] Токен сохранен: \(OAuth2TokenStorage.shared.token ?? "nil")")
                // Загружаем профиль
                ProfileService.shared.fetchProfileInfo(token: token) { [weak self] result in
                    switch result {
                    case .success(let profile):
                        // Загружаем аватарку и переходим
                        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { [weak self] _ in
                            DispatchQueue.main.async {
                                vc.dismiss(animated: true) {
                                    self?.switchToTabBarController()
                                }
                            }
                        }
                    case .failure(let error):
                        print("[AuthViewController]: Ошибка загрузки аватарки - \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            vc.dismiss(animated: true) {
                                self?.switchToTabBarController()
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Auth Error: \(error.localizedDescription)")
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось войти: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    vc.present(alert, animated: true)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
