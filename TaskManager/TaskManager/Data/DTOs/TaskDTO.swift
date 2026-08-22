//
//  TaskDTO.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

struct TaskDTO: Sendable {
    public let id: UUID
    public let title: String
    public let taskDescription: String
    public let status: String
    public let sortOrder: Double
    public let createdAt: Date
    public let updatedAt: Date
}


nonisolated extension TaskDTO: Codable {}
