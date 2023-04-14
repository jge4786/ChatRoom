import Foundation

final class APIService {
    static let shared = APIService()
    
    typealias ChatGPTResult = (Message) -> Void
    typealias RequestResult = (Result<Data, Error>) -> Void
    typealias ResponseResult = (Result<Response, Error>) -> Void
    
    
    private var session = URLSession(configuration: .default)
    
    private enum NetworkError: Error {
        case unauthorized
        case requestTimeout
        case noData
        case unexpectedData
        case badRequest
        case notFound
        case unknownError
       
        var errorMessage: String {
            switch self {
            case .unauthorized:
                return "인증 정보가 잘못되었습니다."
            case .requestTimeout:
                return "응답 시간이 초과하였습니다."
            case .noData:
                return "연결 중 오류가 발생했습니다. - 데이터 없음"
            case .unexpectedData:
                return "연결 중 오류가 발생했습니다. - 잘못된 데이터 수신"
            case .badRequest:
                return "연결 중 오류가 발생했습니다. - 잘못된 데이터 송신"
            case .notFound:
                return "연결 중 오류가 발생했습니다. - 잘못된 API 주소"
            case .unknownError:
                return "알 수 없는 오류"
            }
        }
    }
    
    private enum DefaultSettings {
        static let serverUrl = "https://api.openai.com"                         // API server Url
        static let endPoint = "/v1/chat/completions"                        // API endpoint url
        static let model = "gpt-3.5-turbo"                                  // 사용할 GPT 모델
        static let authorizationMethod = AuthMethod.bearer                  // 사용할 인증 방식
        static let method = "POST"                                          // request method
        
        static let tokenLimit = 500                                          // 응답의 최대 토큰 수
    }
    
    private enum AuthMethod {
        case bearer
    }
    
    private var isLoading = false
    
    
    /// 주어진 Auth 방식으로 헤더 생성
    private func makeHeader(authMethod: AuthMethod, key: String) -> [String : String] {
        var result = ["Content-Type": "application/json"]
        
        
        switch authMethod {
        case .bearer:
            result["Authorization"] = "Bearer \(key)"
        case _:
            break
        }
        
        return result
    }
    
    
    /// URLRequest 생성
    private func makeDataRequest(
        serverUrl: String       = DefaultSettings.serverUrl,
        endpoint: String        = DefaultSettings.endPoint,
        method: String          = DefaultSettings.method,
        authMethod: AuthMethod  = DefaultSettings.authorizationMethod,
        authKey: String,
        bodyData: [String: Any]
    ) -> URLRequest? {
        let url = URL(string: serverUrl + endpoint)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = method
        request.allHTTPHeaderFields = makeHeader(authMethod: authMethod, key: authKey)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyData)
        else {
            return nil }
        
        request.httpBody = jsonData
        
        return request
    }
    
    private func handleNetworkError(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400:
            return NetworkError.badRequest
        case 401:
            return NetworkError.unauthorized
        case 404:
            return NetworkError.notFound
        default:
            return NetworkError.unknownError
        }
    }
    
    private func makeDataTask(
        with request: URLRequest,
        completion: @escaping RequestResult
    ) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode,
               !(200...299).contains(statusCode)
            {
                completion(.failure( self.handleNetworkError(statusCode: statusCode) ))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
        }
        return dataTask
    }
    
    private func makeDataTasks(data: [String: Any],
                               completion: @escaping ResponseResult
    ) -> URLSessionDataTask? {
        guard !isLoading else {
            return nil
        }
        guard let request = makeDataRequest(authKey: APIKey.value, bodyData: data)
        else {
            completion(.failure(NetworkError.badRequest))
            return nil
        }
        
        isLoading = true
        
        let dataTask = makeDataTask(with: request) { result in
            defer { self.isLoading = false }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Response.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print("하나: \(context)")
                    completion( .failure(NetworkError.unexpectedData))
                } catch let DecodingError.keyNotFound(key, context) {
                    print("둘Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion( .failure(NetworkError.unexpectedData))
                } catch let DecodingError.valueNotFound(value, context) {
                    print("셋Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion( .failure(NetworkError.unexpectedData))
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("넷Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion( .failure(NetworkError.unexpectedData))
                } catch {
                    print("다섯error: ", error)
                    completion( .failure(NetworkError.unexpectedData))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if let error = error as? NetworkError {
                        completion( .failure(error) )
                    } else {
                        completion( .failure(error) )
                    }
                }
            }
        }

        dataTask.resume()
        
        return dataTask
    }
}

extension APIService {
    private func makeGPTRequestBody(data: [Message]) -> [String: Any] {
        var messages: [[String: String]] = []
        
        //body 생성
        for (index, datum) in data.enumerated() {
            guard datum.role != "error" else { continue }
            if index + 1 < data.count && data[index + 1].role == "error" { continue }
            
            let tmpArr: [String : String] = ["role" : datum.role, "content" : datum.content]
            
            messages.append(tmpArr)
        }
        
        print(messages)
        
        let jsonBody: [String : Any] = [
            "model": DefaultSettings.model,
            "messages": messages,
            "max_tokens": DefaultSettings.tokenLimit
        ]
        
        return jsonBody
    }
}

// 외부와 연결되는 곳
extension APIService {
    func sendChat(text: [Message], completion: @escaping ChatGPTResult) -> URLSessionDataTask? {
        
        let body = makeGPTRequestBody(data: text)
        
        //요청 송신
        return makeDataTasks(data: body) { result in
            switch result {
            case .success(let data):
                guard let message = data.choices.first?.message else {
                    completion( Message(role: "error", content: NetworkError.unexpectedData.errorMessage) )
                    return
                }

//                DispatchQueue.main.async {
                    completion(message)
//                }
            case .failure(let error):
                completion( Message(role: "error", content: error.localizedDescription) )
            }
        }
    }
    
    func cancelRequest() {
        session.invalidateAndCancel()
        session = URLSession(configuration: .default)
    }
}

struct Response: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var usage: Usage
    var choices: [Choice]
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role, content: String
}

struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
