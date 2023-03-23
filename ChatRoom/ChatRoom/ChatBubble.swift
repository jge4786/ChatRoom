//
//  ChatBubble.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/22.
//

import UIKit

class ChatBubble: UIButton {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(text: String, isMyMessage: Bool) {
        super.init(frame: .zero)
        
        self.setTitle(text, for: .normal)
        
        self.backgroundColor = UIColor(cgColor: isMyMessage ? Color.Yellow : Color.White)
    }
}
