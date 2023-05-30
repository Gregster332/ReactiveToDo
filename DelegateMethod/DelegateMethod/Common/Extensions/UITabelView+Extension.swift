//
//  UITabelView+Extension.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import UIKit

extension UITableView {
    
    func dequeueCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell")
        }
        return cell
    }
    
    func register<T: UITableViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }
    
    func setIsHiddenTrue() {
        UIView.animate(withDuration: 0.5) {
            self.layer.opacity = 0
        } completion: { _ in
            self.isHidden = true
        }
    }

    func setIsHiddenFalse() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.layer.opacity = 1
        }
    }
}
