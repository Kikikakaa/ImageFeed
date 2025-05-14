import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likes: Int
    let isLiked: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likes
        case isLiked = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

final class ImagesListService {

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static var shared = ImagesListService()
    private init() {}
    
    private let authToken = OAuth2TokenStorage.shared.token
    private var currentTask: URLSessionTask?
    private var dataTask: URLSessionTask?
    
    private(set) var photos: [Photo] = []
    private let photosPerPage = 10
    private var lastLoadedPage: Int?
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        guard let authToken else {
            print("Нет токена авторизации")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            print("Ошибка создания URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(photosPerPage)")
        ]
        
        guard let url = urlComponents.url else {
            print("Ошибка формирования URL запроса")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        print("Загрузка страницы \(nextPage)")
        
        let currentTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                print("Загружено фото: \(photoResults.count)")
                
                let newPhotos = photoResults.map {
                    Photo(id: $0.id,
                          size: CGSize(width: $0.width, height: $0.height),
                          createdAt: self.dateFormatter.date(from: $0.createdAt),
                          welcomeDescription: $0.description,
                          thumbImageURL: $0.urls.thumb,
                          largeImageURL: $0.urls.regular,
                          isLiked: $0.isLiked
                    )
                }
                
                let existingIDs = Set(self.photos.map { $0.id })
                let filteredNewPhotos = newPhotos.filter { !existingIDs.contains($0.id) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: filteredNewPhotos)
                    self.lastLoadedPage = nextPage
                    self.currentTask = nil
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
                
            case .failure(let error):
                print("Ошибка загрузки фотографий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.currentTask = nil
                }
            }
        }
        
        self.currentTask = currentTask
        currentTask.resume()
    }
}
