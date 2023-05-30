//
//  UICollectionlView+Extension.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }
    
    func register<T: UICollectionReusableView>(supplementaryViewOfKind kind: String, withClass name: T.Type) {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: name))
    }
    
    func dequeueCell<T: UICollectionViewCell>(with indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell")
        }
        return cell
    }
    
    func dequeueSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: T.self),
            for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView")
        }
        return cell
    }
}
