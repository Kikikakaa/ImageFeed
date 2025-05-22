import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard
            var urlComponents = URLComponents(string: configuration.authURLString)
        else {
            assertionFailure("[AuthHelper|authURL]: Invalid authorization URL string: \(configuration.authURLString)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
            
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        return url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            print("[AuthHelper|code(from url: URL): WKNavigationAction)]: Перенаправление на URL: \(url.absoluteString)")
            print("[AuthHelper|code(from url: URL): WKNavigationAction)]: Код авторизации найден: \(codeItem.value ?? "nil")")
            return codeItem.value
        } else {
            print("[AuthHelper|code(from url: URL): Код авторизации не найден")
            return nil
        }
    }
}
