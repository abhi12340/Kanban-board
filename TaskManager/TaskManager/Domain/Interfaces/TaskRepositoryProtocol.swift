//
//  TaskRepositoryProtocol.swift
//  TaskManager
//
//  Created by Abhishek Kumar on 22/08/26.
//

import Foundation

protocol TaskRepositoryProtocol: Sendable {
    
    func fetchAllTasks() async throws -> [TaskItem]
    
    func createTask(_ task: TaskItem) async throws
    
    func updateTask(_ task: TaskItem) async throws
    
    /// Soft deletes the local task and enqueues a delete mutation
    func deleteTask(id: UUID) async throws
    
    func markAsSynced(taskId: UUID, wasDeletedRemotely: Bool) async throws
    
    func reorderTask(taskId: UUID, to newStatus: TaskStatus, after previousTask: TaskItem?, before nextTask: TaskItem?) async throws
}
