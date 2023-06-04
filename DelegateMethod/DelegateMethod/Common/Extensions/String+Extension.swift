//
//  String+Extension.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 6/3/23.
//

import Foundation

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
}
