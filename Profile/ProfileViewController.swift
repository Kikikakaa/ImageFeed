import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
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
        
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(hex: "FFFFFF")
        configure(descriptionLabel, addTo: view)
        
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        configure(logoutButton, addTo: view)
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
}

