//
//  Task.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 22.05.2025.
//

import Foundation

struct Task {
    let id: UUID
    let title: String
    let description: String
    let createdAt: Date
    let isCompleted: Bool
    
    init(from remote: RemoteTask) {
        self.id = UUID(uuidString: "\(remote.id)") ?? UUID()
        self.title = remote.todo
        self.description = remote.todo
        self.createdAt = Date()
        self.isCompleted = remote.completed
    }
    
}
