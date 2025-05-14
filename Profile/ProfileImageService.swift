import Foundation

struct UserResult: Codable {
    struct ProfileImage: Codable {
        let small: String
    }
    
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print("[ProfileImageService]: avatarURL обновлён -> \(String(describing: avatarURL))")
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self
                )
            }
        }
    }
    
    private var currentTask: URLSessionTask?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    func updateAvatarURL(_ avatarURL: String) {
        self.avatarURL = avatarURL
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        print("[ProfileImageService|fetchProfile]: Отправка запроса для картинки")
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService|fetchProfileImageURL]: Токен не получен")
            DispatchQueue.main.async {
                completion(.failure(ProfileNetworkError.missingToken))
            }
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService|fetchProfileImageURL]: Невозможно создать URL")
            completion(.failure(ProfileNetworkError.urlSessionError))
            return
        }
        
        print("[ProfileImageService|fetchProfileImageURL]: URL успешно создан: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                print("[ProfileImageService|fetchProfileImageURL]: Успешный ответ: \(userResult)")
                let avatarURL = userResult.profileImage.small
                DispatchQueue.main.async {
                    self?.avatarURL = avatarURL  // Обновление avatarURL
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                }
            case .failure(let error):
                print("[ProfileImageService|fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
}
