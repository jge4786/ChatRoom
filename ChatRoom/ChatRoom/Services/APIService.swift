//
//  APIService.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/04/04.
//

import Foundation

class APIService {
    let apiUrl = "https://api.openai.com/v1/chat/completions"
    
    static let config = URLSessionConfiguration.default

    let session = URLSession(configuration: config)

    let API_KEY = "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"
    let defaultModel = "gpt-3.5-turbo"
    let defaultSystemText = "You're a helpful assistant"
    let defaultTemperature = 0.5
    
    private func makeDataTasks(text: String){
        let url = URL(string: apiUrl)
        
        var request = URLRequest(url: url!)
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(API_KEY)",
        ]

        // Create a URLSession request with the endpoint URL and request headers
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let jsonBody = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": "Hello!"]
            ],
            "max_tokens": 50
        ] as [String : Any]
        print("ddd?")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else {
            print("JSON 실패")
            return
        }

        request.httpBody = jsonData

        let dataTask = session.dataTask(with: request) {
            data, response, error in
            let successRange = 200..<300
            guard error == nil,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  successRange.contains(statusCode) else {
                print("aaaaa", (response as? HTTPURLResponse)?.statusCode)
                print("error", error?.localizedDescription)
                return
            }

            guard let resultData = data else {
                print("dsssss")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: resultData)
                
                
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

    func sendChat(text: String) {
        makeDataTasks(text: text)
//        makeDataTasks(url: "/chat/completions", authKey: key, value: ["model" : "gpt-3.5-turbo"], ["message" : Message(text)])
    }
    
}

struct Response: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var usage: Usage
    var choices: [Choice]
    
//    func toString() -> String {
//
//        return "id: \(id)\b\() \() \() \() \()"
//    }
}

//struct Usage: Codable {
//    var prompt_tokens: Int
//    var completion_tokens: Int
//    var total_tokens: Int
//}
//
//struct Choice: Codable {
//    var message: String
//    var finish_reason: String
//    var index: Int
//}
//
//struct Message: Codable {
//    var role: String
//    var content: String
//
//    var jsonData: [String : Codable] {
//        get {
//            return ["role" : role, "content" : content]
//        }
//    }
//
//    init(_ content: String) {
//        self.role = "user"
//        self.content = content
//    }
//}
//
//struct Request: Codable {
//    let model: String
//    let temperature: Double
//    let messages: [Message]
//    let stream: Bool
//}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

// MARK: - Message
struct Message: Codable {
    let role, content: String
}

// MARK: - Usage
struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
