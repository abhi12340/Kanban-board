//
//  TaskItem.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case done = "Done"
}

enum SyncState: String, Codable {
    case synced
    case pendingSync
    case syncFailed
}

struct TaskItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var taskDescription: String
    var status: TaskStatus
    var sortOrder: Double
    var createdAt: Date
    var updatedAt: Date
    var syncState: SyncState
    
    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        status: TaskStatus = .todo,
        sortOrder: Double,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncState: SyncState = .pendingSync
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.status = status
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncState = syncState
    }
}
