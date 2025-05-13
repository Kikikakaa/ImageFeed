import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidURL
    case invalidResponse
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = dataTask(with: request) { data, response, error in

            func fulfillCompletionOnMainThread(_ result: Result<T, Error>) {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            if let error = error {
                print("[URLSession|objectTask]: URLRequestError - \(error.localizedDescription)")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[URLSession|objectTask]: NetworkError - отсутствие HTTP-ответа")
                fulfillCompletionOnMainThread(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                print("[URLSession|objectTask]: HTTPStatusCodeError - Код: \(httpResponse.statusCode), Данные: \(String(data: data ?? Data(), encoding: .utf8) ?? "Нет данных")")
                fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                fulfillCompletionOnMainThread(.success(decodedObject))
            } catch {
                print("[URLSession|objectTask]: DecodingError - \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "Нет данных")")
                fulfillCompletionOnMainThread(.failure(error))
            }
        }
        
        return task
    }
}
