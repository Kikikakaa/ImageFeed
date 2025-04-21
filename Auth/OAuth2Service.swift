import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
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
        do {
            let request = try makeOAuthTokenRequest(code: code)
            let task = URLSession.shared.data(for: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let tokenResponse = try decoder.decode(OAuthTokenResponse.self, from: data)
                        completion(.success(tokenResponse.accessToken))
                    } catch {
                        print("Decoding Error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Network or HTTP Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        } catch {
            print("Ошибка: \(error)")
            completion(.failure(error))
        }
    }
}
