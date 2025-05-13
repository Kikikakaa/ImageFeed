import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func makeOAuthTokenRequest(code: String) throws -> URLRequest {
        let baseURL = URL(string: Constants.baseURL)
        guard let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"
             + "&&client_secret=\(Constants.secretKey)"
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL
        ) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[OAuth2Service|fetchAuthToken]:  Код не совпадает")
            completion(.failure(AuthServiceError.invalidRequest))
            return
         }

         task?.cancel()
         lastCode = code
        
        do {
            let request = try makeOAuthTokenRequest(code: code)
            let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result <OAuthTokenResponse, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let tokenResponse):
                            completion(.success(tokenResponse.accessToken))
                    case .failure(let error):
                        print("[OAuth2Service|fetchAuthToken]: Network or HTTP Error -  \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                    self?.task = nil
                    self?.lastCode = nil
                }
            }
            self.task = task
            task.resume()
        } catch {
            DispatchQueue.main.async {
                print("[OAuth2Service|fetchAuthToken]: Ошибка - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
