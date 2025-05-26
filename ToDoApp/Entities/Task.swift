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
    
    init(id: UUID, title: String, description: String, createdAt: Date, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
    
    init(from remote: RemoteTask) {
        self.id = UUID(uuidString: "\(remote.id)") ?? UUID()
        self.title = remote.todo
        self.description = remote.todo
        self.createdAt = Date()
        self.isCompleted = remote.completed
    }
    
    init(from entity: TaskEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.description = entity.descriptionText ?? ""
        self.createdAt = entity.createdAt ?? Date()
        self.isCompleted = entity.isCompleted
    }
    
}
