//
//  Date+Extensions.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 25.05.2025.
//

import Foundation

extension Date {
    var dateString: String { DateFormatter.defaultDateFormatter.string(from: self) }
}

extension DateFormatter {
    static let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter
    }()
}
