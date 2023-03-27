//
//  Chat.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/23.
//

import Foundation

struct Chat: Codable {
    let owner: User
    let sentDateTime: String
    var unreadCount: Int
    let text: String
    let image: String
    
    var sentDate: String {
        get {
            String(sentDateTime.split(separator: " ")[0])
        }
    }
    
    var sentTime: String {
        get {
            String(sentDateTime.split(separator: " ")[1])
        }
    }
    
    init() {
        self.owner = User()
        self.sentDateTime = "1900-01-01 00:01"
        self.unreadCount = 0
        self.text = ""
        self.image = ""
    }
    
    init(owner: User, sentDateTime: String, text: String = "", unreadCount: Int = 0, image: String = "") {
        self.owner = owner
        self.sentDateTime = sentDateTime
        self.unreadCount = unreadCount
        self.text = text
        self.image = image
        
    }
    
    func toString() -> String {
        return "[owner: " + owner.toString() + ", sentDateTime: " + sentDateTime + ", unreadCount: " + String(unreadCount) + "]"
    }
}
