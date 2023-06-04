//
//  Date+Extension.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 6/3/23.
//

import Foundation

extension Date {
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: self)
    }
    
    private func get(_ dateComponent: Calendar.Component) -> Int {
        let calendar = Calendar.current
        return calendar.component(dateComponent, from: self)
    }
    
    func isHigher(then date: Date) -> Bool {
        return self.get(.day) == date.get(.day) && self.get(.month) == date.get(.month) && self.get(.year) == date.get(.year)
    }
    
    func createDateAfter(with daysCount: Int) -> Date {
        if let constructedDate = Calendar.current.date(byAdding: .day, value: daysCount, to: self) {
            return constructedDate
        } else {
            return self
        }
    }
}
