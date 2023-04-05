//
//  APIService.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/04/04.
//

import Foundation

final class APIService {
    public static let shared = APIService()
    
    private enum DefaultSettings {
        static let apiUrl = "https://api.openai.com/v1/chat/completions"
        static let apiKey = "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"
        static let model = "gpt-3.5-turbo"
        static let systemText = "You're a helpful assistant"
        static let temperature: Double = 0.5
        static let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(DefaultSettings.apiKey)",
        ]
        static let method = "POST"
        
        static let tokenLimit = 50
    }

    let session = URLSession(configuration: .default)

    var isLoading = false
        
    typealias ChatGPTResult = (Response) -> Void
        
    private func makeDataRequest(method: String = DefaultSettings.method, data text: String) -> URLRequest? {
        let url = URL(string: DefaultSettings.apiUrl)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = method
        request.allHTTPHeaderFields = DefaultSettings.headers
        
        let jsonBody = [
            "model": DefaultSettings.model,
            "messages": [
                ["role": "user", "content": text]
            ],
            "max_tokens": DefaultSettings.tokenLimit
        ] as [String : Any]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else {
            print("JSON 실패")
            return nil
        }

        request.httpBody = jsonData
        
        return request
    }
    
    private func makeDataTasks(text: String, completion: @escaping ChatGPTResult){
        guard !isLoading,
              let request = makeDataRequest(data: text)
        else {
            return
        }

        isLoading = true
        
        let dataTask = session.dataTask(with: request) {
            data, response, error in
            
            defer { self.isLoading = false }
            
            let successRange = 200..<300
            guard error == nil,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  successRange.contains(statusCode),
                  let data = data
            else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                
                DispatchQueue.global().async {
                    completion(response)
                }
                
                dump(response)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }

        dataTask.resume()
    }
}

// 외부와 연결되는 곳
extension APIService {
    func sendChat(text: String, completion: @escaping ChatGPTResult) {
        makeDataTasks(text: text, completion: completion)
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
