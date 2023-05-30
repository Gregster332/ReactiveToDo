//
//  Do.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

#if canImport(Foundation)
import Foundation
#endif
#if !os(Linux)
import CoreGraphics
#endif
#if os(iOS) || os(tvOS)
import UIKit.UIGeometry
#endif

protocol Do {}

extension Do where Self: Any {
    
    @inlinable
    @discardableResult func `do`(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

extension NSObject: Do {}

#if !os(Linux)
extension CGPoint: Do {}
extension CGRect: Do {}
extension CGSize: Do {}
extension CGVector: Do {}
#endif

extension Array: Do {}
extension Dictionary: Do {}
extension Set: Do {}

#if os(iOS) || os(tvOS)
extension UIEdgeInsets: Do {}
extension UIOffset: Do {}
extension UIRectEdge: Do {}
#endif

