//
//  Task.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import Foundation

struct Task {
    let title: String
    let description: String
    let createdAt: Date
    let isCompleted: Bool
    
    static let mockData: [Task] = [
        Task(title: "Buy milk", description: "Get 2 liters", createdAt: Date(), isCompleted: false),
        Task(title: "Do homework", description: "Finish math exercises", createdAt: Date(), isCompleted: true)
    ]
}
