import UIKit
import Kingfisher
import SwiftKeychainWrapper

protocol ProfileViewProtocol: AnyObject {
    func displayProfile(name: String, login: String, bio: String?)
    func displayAvatar(url: URL?)
    func navigateToSplashScreen()
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    // MARK: - UI Components
    
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    private let profileImageView = UIImageView()
    var presenter: ProfilePresenterProtocol!

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        presenter = ProfilePresenter()
        presenter.view = self
        profileImageView.clipsToBounds = true
        view.backgroundColor = UIColor(resource: .ypBlack)
        presenter.viewDidLoad()
        logoutButton.accessibilityIdentifier = "Logout"
    }
    
    @objc
    private func didTapButton() {
        showLogoutAlert()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter.didConfirmLogout() 
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        profileImageView.image = UIImage(named: "Avatar")
        configure(profileImageView, addTo: view)
        
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = UIColor(hex: "FFFFFF")
        configure(nameLabel, addTo: view)
        
        tagLabel.text = "@ekaterina_nov"
        tagLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tagLabel.textColor = UIColor(hex: "AEAFB4")
        configure(tagLabel, addTo: view)
        
        descriptionLabel.text = "Hello, world"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(hex: "FFFFFF")
        configure(descriptionLabel, addTo: view)
        
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        configure(logoutButton, addTo: view)
        
        logoutButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            tagLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            tagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        print("Logout button tapped")
    }
    
    // MARK: - Helpers
    
    private func configure(_ view: UIView, addTo parent: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(view)
    }
    
    func navigateToSplashScreen() {
        let splashViewController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Нет доступного окна")
        }
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }
    
    func displayProfile(name: String, login: String, bio: String?) {
        nameLabel.text = name
        tagLabel.text = login
        descriptionLabel.text = bio
    }
    
    func displayAvatar(url: URL?) {
        if let url = url {
            let processor = RoundCornerImageProcessor(cornerRadius: 50, backgroundColor: .ypBlack)
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "UserPhoto"),
                options: [
                    .processor(processor),
                    .transition(.fade(0.3))
                ]
            ) { result in
                switch result {
                case .success(let value):
                    print("[ProfileViewController|updateAvatar]: Аватарка успешно загружена с URL: \(value.source.url?.absoluteString ?? "неизвестно")")
                case .failure(let error):
                    print("[ProfileViewController|updateAvatar]: Ошибка при загрузке аватарки: \(error.localizedDescription)")
                    self.profileImageView.image = UIImage(named: "UserPhoto")
                }
            }
        } else {
            profileImageView.image = UIImage(named: "UserPhoto")
        }
    }
}

