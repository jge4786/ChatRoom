//
//  TableViewCellBase.swift
//  ChatRoom
//
//  Created by 여보야 on 2023/03/23.
//

import UIKit

protocol TableViewCellBase {
    static func register(tableView: UITableView)
    static func dequeueReusableCell(tableView: UITableView) -> Self
    static var reuseIdentifier: String { get }
    static var NibName: String { get }
}

extension TableViewCellBase where Self: UITableViewCell {
    static func register(tableView: UITableView) {
        let Nib = UINib(nibName: self.NibName, bundle: nil)
        tableView.register(Nib, forCellReuseIdentifier: self.reuseIdentifier)
    }
    
    static func dequeueReusableCell(tableView: UITableView) -> Self {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) as? Self else {
            fatalError("Error! \(self.reuseIdentifier)")
        }
        
        return cell
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var NibName: String {
        return String(describing: self)
    }
}
