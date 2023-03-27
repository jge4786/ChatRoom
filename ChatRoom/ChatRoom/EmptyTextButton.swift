//
//  EmptyTextButton.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/23.
//

import UIKit

class EmptyTextButton: UIButton {
    init() {
        super.init(frame: .zero)
        self.setTitle("", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    setTitle("", for: .normal)
}
