import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    private let profileService = ProfileService.shared
    private let profileImageView = UIImageView()
    private var profile: Profile?
    private var profileObserver: NSObjectProtocol?
    private var profileImageObserver: NSObjectProtocol?

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        profileImageView.clipsToBounds = true
        view.backgroundColor = UIColor(resource: .ypBlack)
        
        profileObserver = NotificationCenter.default.addObserver(
            forName: ProfileService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("[ProfileViewController]: Получено обновление профиля")
            DispatchQueue.main.async {
                   self?.updateProfile()
               }
           }
        
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("[ProfileViewController]: Получено обновление аватарки")
            DispatchQueue.main.async {
                  self?.updateAvatar()
              }
          }
        
        updateProfile()
        updateAvatar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfile()
        updateAvatar()
    }
    
    @objc
    private func didTapButton() {
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
            UIApplication.shared.windows.first?.rootViewController = SplashViewController()
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
    
    private func updateProfile() {
        guard let profile = ProfileService.shared.profile else {
            print("Missing profile")
            nameLabel.text = "No Name"
            tagLabel.text = "No Login"
            descriptionLabel.text = "No Bio"
            return
        }
    
        nameLabel.text = profile.name.isEmpty ? "No Name" : profile.name
        tagLabel.text = profile.loginName.isEmpty ? "No Login" : profile.loginName
        descriptionLabel.text = profile.bio?.isEmpty == false ? profile.bio : "No Bio"
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            !profileImageURL.isEmpty else {
            profileImageView.image = UIImage(named: "UserPhoto")
            print("[ProfileViewController|updateAvatar]: Ошибка: avatarURL отсутствует")
            return
        }
                
        guard let url = URL(string: profileImageURL) else {
            profileImageView.image = UIImage(named: "UserPhoto")
            print("[ProfileViewController|updateAvatar]: Ошибка: avatarURL")
            return
        }

        let processor = RoundCornerImageProcessor(cornerRadius: 61,
                                                  backgroundColor: UIColor(hex: "1A1B22"))
        
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "UserPhoto"),
            options: [
                .processor(processor),
                .transition(.fade(0.3))
            ]) { result in
                switch result {
                case .success:
                    print("[ProfileViewController|updateAvatar]: Аватарка успешно загружена с URL")
                case .failure(let error):
                    print("[ProfileViewController|updateAvatar]: Ошибка при загрузке аватарки: \(error.localizedDescription)")
                }
            }
    }
}

