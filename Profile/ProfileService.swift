import Foundation

struct ProfileResult: Codable {
    let username: String
    let name: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = [profileResult.firstName, profileResult.lastName] .compactMap { $0 }.joined(separator: " ")
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}

enum ProfileNetworkError: Error {
    case requestCancelled
    case urlSessionError
    case urlSessionRequestError
    case missingToken
}

final class ProfileService {
    private var currentTask: URLSessionTask?
    static var shared = ProfileService()
    private init() {}
    var profile: Profile? {
        didSet {
            NotificationCenter.default.post(
                name: ProfileService.didChangeNotification,
                object: self
            )
        }
    }
    static let didChangeNotification = Notification.Name("ProfileServiceDidChange")
    
    func updateProfile(_ profile: Profile) {
        self.profile = profile
    }
    
    private func createAuthRequest(url: URL, token: String) -> URLRequest? {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[ProfileService] Заголовок Authorization: \(request.value(forHTTPHeaderField: "Authorization") ?? "nil")")
        return request
    }
    
    func fetchProfileInfo(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        print("[ProfileService] Запуск запроса профиля...")
        currentTask?.cancel()
        
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Incorrect URL")
            completion(.failure(ProfileNetworkError.urlSessionError))
            return
        }
        print("[ProfileService] URL создан: \(url.absoluteString)")
        
        guard let request = createAuthRequest(url: url, token: token) else {
            print("URLRequest error")
            completion(.failure(ProfileNetworkError.requestCancelled))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self]
            (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self?.profile = profile
                print("Профиль сохранен: \(profile)")
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService|fetchProfileInfo]: Ошибка - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.currentTask = task
        task.resume()
    }
    
    func clearProfile() {
        profile = nil
        NotificationCenter.default.post(name: ProfileService.didChangeNotification, object: self)
        print("Профиль удален")
    }
}

    


